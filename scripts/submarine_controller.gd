class_name SubmarineController
extends CharacterBody3D

signal telemetry_updated(depth: float, speed: float, decibels: float)
signal gear_changed(gear_name: String)
signal silent_running_status(active: bool, time_left: float)
signal evasion_window_triggered(duration: float)
signal crush_depth_warning(is_warning: bool)

enum Gear { STOP, SLOW, CRUISE, FLANK, SILENT }

@export_group("Hydrodynamic Properties")
@export var mass: float = 5000.0 # Submarine mass in kg
@export var max_speed: float = 30.0
@export var acceleration: float = 6.0
@export var linear_drag: float = 1.8
@export var angular_drag: float = 3.0
@export var max_turn_speed: float = 1.0
@export var max_pitch_speed: float = 0.8
@export var ballast_heave_speed: float = 10.0
@export var crush_depth: float = 500.0 # Depth limit in meters

@export_group("Submarine Telemetry")
@export var current_gear: Gear = Gear.STOP
@export var current_decibels: float = 0.0
@export var current_depth: float = 100.0 # Depth in meters

# Stealth & Silent Running
var silent_running_active: bool = false
var silent_running_timer: float = 0.0
var silent_running_cooldown_timer: float = 0.0
const SILENT_RUNNING_MAX_TIME: float = 15.0
const SILENT_RUNNING_COOLDOWN: float = 30.0

# Evasion Window
var evasion_active: bool = false
var evasion_timer: float = 0.0

# Terrain scraping state
var is_scraping_terrain: bool = false

# Steering inputs (-1.0 to 1.0)
var input_yaw: float = 0.0
var input_pitch: float = 0.0
var input_heave: float = 0.0 # Ballast control (-1 down, +1 up)

# Velocities
var local_velocity: Vector3 = Vector3.ZERO
var angular_velocity: Vector3 = Vector3.ZERO

func _physics_process(delta: float) -> void:
	if Input.is_key_pressed(KEY_1): set_gear(Gear.STOP)
	if Input.is_key_pressed(KEY_2): set_gear(Gear.SLOW)
	if Input.is_key_pressed(KEY_3): set_gear(Gear.CRUISE)
	if Input.is_key_pressed(KEY_4): set_gear(Gear.FLANK)
	if Input.is_key_pressed(KEY_5): set_gear(Gear.SILENT)

	_update_timers(delta)
	_process_hydrodynamics(delta)
	_update_decibels()
	_check_crush_depth()

	telemetry_updated.emit(current_depth, velocity.length(), current_decibels)

func set_gear(gear: Gear) -> void:
	if gear == Gear.SILENT:
		if silent_running_cooldown_timer > 0.0:
			print("Silent running on cooldown!")
			return
		activate_silent_running()
	else:
		if silent_running_active:
			deactivate_silent_running()
		current_gear = gear
		gear_changed.emit(_gear_to_string(current_gear))

func activate_silent_running() -> void:
	if silent_running_cooldown_timer <= 0.0:
		silent_running_active = true
		silent_running_timer = SILENT_RUNNING_MAX_TIME
		current_gear = Gear.SILENT
		gear_changed.emit("SILENT")

func deactivate_silent_running() -> void:
	silent_running_active = false
	silent_running_timer = 0.0
	silent_running_cooldown_timer = SILENT_RUNNING_COOLDOWN
	if current_gear == Gear.SILENT:
		current_gear = Gear.STOP
		gear_changed.emit("STOP")

func _update_timers(delta: float) -> void:
	if silent_running_active:
		silent_running_timer -= delta
		silent_running_status.emit(true, silent_running_timer)
		if silent_running_timer <= 0.0:
			deactivate_silent_running()
	elif silent_running_cooldown_timer > 0.0:
		silent_running_cooldown_timer -= delta
		silent_running_status.emit(false, silent_running_cooldown_timer)

	if evasion_active:
		evasion_timer -= delta
		if evasion_timer <= 0.0:
			evasion_active = false

func trigger_evasion_window(duration: float = 2.5) -> void:
	evasion_active = true
	evasion_timer = duration
	evasion_window_triggered.emit(duration)

func execute_crash_dive() -> void:
	input_pitch = -1.0
	input_heave = -1.0
	set_gear(Gear.FLANK)

func execute_emergency_reverse() -> void:
	local_velocity.z = max_speed * 0.5

func _process_hydrodynamics(delta: float) -> void:
	var k_yaw: float = Input.get_axis("ui_right", "ui_left")
	var k_pitch: float = Input.get_axis("ui_up", "ui_down")
	if k_yaw != 0.0: input_yaw = k_yaw
	if k_pitch != 0.0: input_pitch = k_pitch
	if not Input.is_key_pressed(KEY_W) and not Input.is_key_pressed(KEY_S) and not Input.is_key_pressed(KEY_A) and not Input.is_key_pressed(KEY_D) and not Input.is_key_pressed(KEY_UP) and not Input.is_key_pressed(KEY_DOWN) and not Input.is_key_pressed(KEY_LEFT) and not Input.is_key_pressed(KEY_RIGHT):
		input_yaw = move_toward(input_yaw, 0.0, delta * 2.0)
		input_pitch = move_toward(input_pitch, 0.0, delta * 2.0)

	var k_heave: float = 0.0
	if Input.is_key_pressed(KEY_E): k_heave += 1.0
	if Input.is_key_pressed(KEY_Q): k_heave -= 1.0
	if k_heave != 0.0: input_heave = k_heave
	if not Input.is_key_pressed(KEY_E) and not Input.is_key_pressed(KEY_Q):
		input_heave = move_toward(input_heave, 0.0, delta * 2.0)

	# Calculate depth
	current_depth = max(0.0, -global_transform.origin.y + 100.0)

	# Dynamic steering: turn rate scales with current forward speed ratio
	var forward_speed_ratio: float = clamp(abs(local_velocity.z) / max_speed, 0.05, 1.0)
	var effective_turn_speed: float = max_turn_speed * forward_speed_ratio

	# Target angular speed
	var target_angular_y: float = -input_yaw * effective_turn_speed
	var target_angular_x: float = input_pitch * max_pitch_speed

	angular_velocity.y = move_toward(angular_velocity.y, target_angular_y, acceleration * delta)
	angular_velocity.x = move_toward(angular_velocity.x, target_angular_x, acceleration * delta)

	# Apply angular drag damping
	angular_velocity = angular_velocity.move_toward(Vector3.ZERO, angular_drag * delta)

	rotate_object_local(Vector3.UP, angular_velocity.y * delta)
	rotate_object_local(Vector3.RIGHT, angular_velocity.x * delta)

	# Determine thrust based on gear
	var gear_ratio: float = _get_gear_ratio()
	var target_forward_speed: float = max_speed * gear_ratio

	var target_local_vel: Vector3 = Vector3(
		0.0,
		input_heave * ballast_heave_speed,
		-target_forward_speed
	)

	# Smoothly apply linear momentum and hydrodynamic drag
	local_velocity = local_velocity.move_toward(target_local_vel, acceleration * delta)
	local_velocity = local_velocity.move_toward(Vector3.ZERO, linear_drag * delta)

	velocity = transform.basis * local_velocity
	var collided = move_and_slide()
	if collided and get_slide_collision_count() > 0:
		is_scraping_terrain = true
	else:
		is_scraping_terrain = false

func _get_gear_ratio() -> float:
	match current_gear:
		Gear.STOP: return 0.0
		Gear.SLOW: return 0.30
		Gear.CRUISE: return 0.65
		Gear.FLANK: return 1.00
		Gear.SILENT: return 0.20
		_: return 0.0

func _update_decibels() -> void:
	if silent_running_active:
		current_decibels = 0.0
		return

	var base_db: float = 0.0
	match current_gear:
		Gear.STOP: base_db = 0.0
		Gear.SLOW: base_db = 10.0
		Gear.CRUISE: base_db = 45.0
		Gear.FLANK: base_db = 90.0 # Propeller cavitation

	# Add extra noise if scraping terrain
	if is_scraping_terrain:
		base_db += 30.0

	# Add extra noise from weapons system transient
	var weapons_sys = get_node_or_null("WeaponsSystem") as WeaponsSystem
	if weapons_sys and weapons_sys.transient_exposure_timer > 0.0:
		base_db = max(base_db, 100.0)

	current_decibels = base_db

func _check_crush_depth() -> void:
	if current_depth > crush_depth:
		crush_depth_warning.emit(true)
		var defense_sys = get_node_or_null("DefenseSystem") as DefenseSystem
		if defense_sys:
			defense_sys.apply_damage(10.0 * get_process_delta_time(), self)
	else:
		crush_depth_warning.emit(false)

func _gear_to_string(gear: Gear) -> String:
	match gear:
		Gear.STOP: return "STOP"
		Gear.SLOW: return "SLOW"
		Gear.CRUISE: return "CRUISE"
		Gear.FLANK: return "FLANK"
		Gear.SILENT: return "SILENT"
		_: return "UNKNOWN"
