class_name SubmarineController
extends CharacterBody3D

signal telemetry_updated(depth: float, speed: float, decibels: float)
signal gear_changed(gear_name: String)
signal silent_running_status(active: bool, time_left: float)
signal evasion_window_triggered(duration: float)

enum Gear { STOP, SLOW, CRUISE, FLANK, SILENT }

@export_group("Physics Properties")
@export var max_speed: float = 30.0
@export var acceleration: float = 8.0
@export var drag: float = 2.0
@export var turn_speed: float = 1.2
@export var pitch_speed: float = 1.0
@export var ballast_heave_speed: float = 12.0

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

# Evasion Window (Synergy with Defense Officer)
var evasion_active: bool = false
var evasion_timer: float = 0.0

# Steering inputs (-1.0 to 1.0)
var input_yaw: float = 0.0
var input_pitch: float = 0.0
var input_heave: float = 0.0 # Ballast control (-1 down, +1 up)

# Linear velocity vector in local space
var local_velocity: Vector3 = Vector3.ZERO

func _physics_process(delta: float) -> void:
	_update_timers(delta)
	_process_movement(delta)
	_update_decibels()

	# Update depth from global Y position (assuming Surface is Y=0, Depth increases as Y decreases)
	current_depth = max(0.0, -global_transform.origin.y + 100.0)

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
	# Rapid ballast purge and max downward pitch
	input_pitch = -1.0
	input_heave = -1.0
	set_gear(Gear.FLANK)

func execute_emergency_reverse() -> void:
	# Reverse pulse
	velocity = -transform.basis.z * (max_speed * 0.5)

func _process_movement(delta: float) -> void:
	# Rotate submarine based on inputs (Yaw, Pitch)
	rotate_object_local(Vector3.UP, -input_yaw * turn_speed * delta)
	rotate_object_local(Vector3.RIGHT, input_pitch * pitch_speed * delta)

	# Determine target thrust speed based on gear ratio
	var gear_ratio: float = _get_gear_ratio()
	var target_forward_speed: float = max_speed * gear_ratio

	# Calculate desired local velocity
	var target_local_vel: Vector3 = Vector3(
		0.0,
		input_heave * ballast_heave_speed,
		-target_forward_speed
	)

	# Smoothly interpolate current local velocity with drag and acceleration
	local_velocity = local_velocity.move_toward(target_local_vel, acceleration * delta)
	local_velocity = local_velocity.move_toward(Vector3.ZERO, drag * delta * 0.1)

	# Transform local velocity to world space and apply move_and_slide
	velocity = transform.basis * local_velocity
	move_and_slide()

func _get_gear_ratio() -> float:
	match current_gear:
		Gear.STOP:
			return 0.0
		Gear.SLOW:
			return 0.30
		Gear.CRUISE:
			return 0.65
		Gear.FLANK:
			return 1.00
		Gear.SILENT:
			return 0.20
		_:
			return 0.0

func _update_decibels() -> void:
	if silent_running_active:
		current_decibels = 0.0
		return

	match current_gear:
		Gear.STOP:
			current_decibels = 0.0
		Gear.SLOW:
			current_decibels = 10.0
		Gear.CRUISE:
			current_decibels = 45.0
		Gear.FLANK:
			current_decibels = 90.0
		_:
			current_decibels = 0.0

func _gear_to_string(gear: Gear) -> String:
	match gear:
		Gear.STOP: return "STOP"
		Gear.SLOW: return "SLOW"
		Gear.CRUISE: return "CRUISE"
		Gear.FLANK: return "FLANK"
		Gear.SILENT: return "SILENT"
		_: return "UNKNOWN"
