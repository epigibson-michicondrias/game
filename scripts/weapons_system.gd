class_name WeaponsSystem
extends Node3D

signal weapon_fired(slot_index: int, weapon_name: String)
signal weapon_cooldown_started(slot_index: int, duration: float)
signal weapon_cooldown_updated(slot_index: int, time_left: float)
signal hull_ability_used(ability_index: int, ability_name: String)
signal acoustic_transient_alert(duration: float)
signal target_lead_calculated(lead_position: Vector3, is_stabilized: bool)

@export var torpedo_scene: PackedScene = preload("res://scenes/weapons/torpedo.tscn")

# Firing Transient
var transient_exposure_timer: float = 0.0
const ACOUSTIC_TRANSIENT_DURATION: float = 5.0 # 5 seconds exposure on enemy radar

# Weapon Slots Configuration
var weapon_names: Array[String] = [
	"Heavy Torpedo",
	"Supercavitating Rocket",
	"EMP / Sub-Sea Mines"
]
var weapon_cooldowns: Array[float] = [8.0, 4.0, 12.0] # Total cooldown times
var weapon_timers: Array[float] = [0.0, 0.0, 0.0]     # Current cooldown timers
var weapon_speeds: Array[float] = [40.0, 120.0, 15.0]  # Projectile speeds (m/s)
var weapon_damages: Array[float] = [180.0, 90.0, 120.0]

# Fixed Hull Abilities
var ability_names: Array[String] = ["Heavy Hull Slam", "Sonar Shockwave"]
var ability_cooldowns: Array[float] = [20.0, 30.0]
var ability_timers: Array[float] = [0.0, 0.0]

# Target Tracking
var target_node: Node3D = null
var is_target_pinged_by_navigator: bool = false

func _process(delta: float) -> void:
	_update_cooldowns(delta)
	_update_acoustic_transient(delta)
	_calculate_lead_vector()

func _update_cooldowns(delta: float) -> void:
	for i in range(weapon_timers.size()):
		if weapon_timers[i] > 0.0:
			weapon_timers[i] -= delta
			weapon_cooldown_updated.emit(i, weapon_timers[i])

	for i in range(ability_timers.size()):
		if ability_timers[i] > 0.0:
			ability_timers[i] -= delta

func _update_acoustic_transient(delta: float) -> void:
	if transient_exposure_timer > 0.0:
		transient_exposure_timer -= delta

func fire_weapon(slot_index: int) -> bool:
	if slot_index < 0 or slot_index >= weapon_names.size():
		return false

	if weapon_timers[slot_index] > 0.0:
		print("Weapon slot %d on cooldown!" % slot_index)
		return false

	# Trigger cooldown
	weapon_timers[slot_index] = weapon_cooldowns[slot_index]
	weapon_cooldown_started.emit(slot_index, weapon_cooldowns[slot_index])
	weapon_fired.emit(slot_index, weapon_names[slot_index])

	# Spawn Torpedo projectile
	_spawn_torpedo_projectile(slot_index)

	# Acoustic transient penalty: 100 dB spike for 5 seconds on enemy minimap
	trigger_acoustic_transient()
	return true

func _spawn_torpedo_projectile(slot_index: int) -> void:
	if torpedo_scene == null:
		return

	var torpedo_instance = torpedo_scene.instantiate() as Torpedo
	if torpedo_instance:
		torpedo_instance.launcher_node = get_parent() as Node3D
		torpedo_instance.speed = weapon_speeds[slot_index]
		torpedo_instance.damage = weapon_damages[slot_index]
		torpedo_instance.target_node = target_node

		# Position at weapon muzzle / submarine front
		get_tree().root.add_child(torpedo_instance)
		torpedo_instance.global_transform = global_transform

func use_hull_ability(ability_index: int) -> bool:
	if ability_index < 0 or ability_index >= ability_names.size():
		return false

	if ability_timers[ability_index] > 0.0:
		print("Hull ability %d on cooldown!" % ability_index)
		return false

	ability_timers[ability_index] = ability_cooldowns[ability_index]
	hull_ability_used.emit(ability_index, ability_names[ability_index])

	if ability_index == 0:
		trigger_acoustic_transient()
	return true

func trigger_acoustic_transient() -> void:
	transient_exposure_timer = ACOUSTIC_TRANSIENT_DURATION
	acoustic_transient_alert.emit(ACOUSTIC_TRANSIENT_DURATION)

func set_target_pinged(pinged: bool) -> void:
	is_target_pinged_by_navigator = pinged

func reset_all_cooldowns() -> void:
	for i in range(weapon_timers.size()):
		weapon_timers[i] = 0.0
		weapon_cooldown_updated.emit(i, 0.0)
	for i in range(ability_timers.size()):
		ability_timers[i] = 0.0

func _calculate_lead_vector() -> void:
	if target_node == null:
		return

	var shooter_pos: Vector3 = global_transform.origin
	var target_pos: Vector3 = target_node.global_transform.origin
	var target_vel: Vector3 = Vector3.ZERO

	if target_node is CharacterBody3D:
		target_vel = target_node.velocity

	var proj_speed: float = weapon_speeds[0] # Primary torpedo speed
	var dist: float = shooter_pos.distance_to(target_pos)
	var time_to_target: float = dist / max(proj_speed, 1.0)

	# Intercept lead calculation
	var predicted_lead_pos: Vector3 = target_pos + (target_vel * time_to_target)

	target_lead_calculated.emit(predicted_lead_pos, is_target_pinged_by_navigator)
