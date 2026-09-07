class_name DefenseSystem
extends Node3D

signal radar_targets_updated(targets: Array)
signal incoming_threat_detected(threat_id: String, tti: float)
signal evasion_order_issued(reaction_window: float)
signal countermeasure_deployed(countermeasure_type: String)
signal repair_progress_updated(system_name: String, progress: float)
signal system_repaired(system_name: String)

enum CountermeasureType { NOISEMAKER, MICROBUBBLE_SCREEN, HARD_KILL }

# Damage Control Minigame State Machines
enum MinigameType { NONE, HULL_BREACH, ENGINE_CALIBRATION, CIRCUIT_BREAKER }

@export var radar_range: float = 1000.0

# Damage & Hull Integrity
var hull_health: float = 100.0
var max_hull_health: float = 100.0

# Threat Tracking
var tracked_threats: Dictionary = {} # threat_id -> { "pos": Vector3, "speed": float, "dist": float, "tti": float }

# Evasion Order Synergy
var evasion_order_active: bool = false
const EVASION_WINDOW_DURATION: float = 2.5 # 2.5 seconds window for Navigator to dodge

# Active Minigame State
var current_minigame: MinigameType = MinigameType.NONE
var minigame_progress: float = 0.0 # 0 to 100

# Hull Breach minigame: requires taps
var breach_taps_required: int = 5
var breach_taps_current: int = 0

# Engine Calibration: target slider value (0.0 to 1.0)
var target_calibration_value: float = 0.75
var current_calibration_value: float = 0.0

# Circuit Breaker: toggles active
var breakers_state: Array[bool] = [false, false, false, false]

func _process(delta: float) -> void:
	_update_radar(delta)
	_update_threat_tti(delta)

func _update_radar(delta: float) -> void:
	# Simulates scanning for incoming threats and returning radar data
	var targets: Array = []
	for threat_id in tracked_threats.keys():
		var threat_info = tracked_threats[threat_id]
		targets.append({
			"id": threat_id,
			"position": threat_info["pos"],
			"distance": threat_info["dist"],
			"tti": threat_info["tti"]
		})
	radar_targets_updated.emit(targets)

func simulate_incoming_torpedo(threat_id: String, start_distance: float = 800.0, speed: float = 50.0) -> void:
	var tti: float = start_distance / speed
	tracked_threats[threat_id] = {
		"pos": Vector3(0, 0, -start_distance),
		"speed": speed,
		"dist": start_distance,
		"tti": tti
	}
	incoming_threat_detected.emit(threat_id, tti)

func _update_threat_tti(delta: float) -> void:
	var keys_to_remove: Array = []
	for threat_id in tracked_threats.keys():
		var threat = tracked_threats[threat_id]
		threat["dist"] -= threat["speed"] * delta
		threat["tti"] = max(0.0, threat["dist"] / threat["speed"])

		# Auto trigger evasion alert if TTI is under 3 seconds
		if threat["tti"] <= 3.0 and not evasion_order_active:
			issue_evasion_order()

		if threat["dist"] <= 0.0:
			keys_to_remove.append(threat_id)

	for id in keys_to_remove:
		tracked_threats.erase(id)

func issue_evasion_order() -> void:
	evasion_order_active = true
	evasion_order_issued.emit(EVASION_WINDOW_DURATION)

	# Notify attached SubmarineController if present
	var sub_controller = get_parent() as SubmarineController
	if sub_controller:
		sub_controller.trigger_evasion_window(EVASION_WINDOW_DURATION)

func deploy_countermeasure(cm_type: CountermeasureType) -> void:
	var type_str: String = ""
	match cm_type:
		CountermeasureType.NOISEMAKER:
			type_str = "NOISEMAKER DECOY"
			_neutralize_closest_threat()
		CountermeasureType.MICROBUBBLE_SCREEN:
			type_str = "MICROBUBBLE SCREEN"
		CountermeasureType.HARD_KILL:
			type_str = "CLOSE-IN HARD KILL"
			_neutralize_closest_threat()
	countermeasure_deployed.emit(type_str)

func _neutralize_closest_threat() -> void:
	var min_dist: float = 999999.0
	var closest_id: String = ""
	for threat_id in tracked_threats.keys():
		if tracked_threats[threat_id]["dist"] < min_dist:
			min_dist = tracked_threats[threat_id]["dist"]
			closest_id = threat_id

	if closest_id != "":
		tracked_threats.erase(closest_id)

func apply_damage(amount: float, sub_controller: SubmarineController = null) -> float:
	var final_damage: float = amount
	if sub_controller != null and sub_controller.evasion_active:
		# 80% damage reduction during evasion window
		final_damage = amount * 0.20
		print("EVASION SUCCESSFUL! Damage reduced by 80%. Final damage: ", final_damage)

	hull_health = max(0.0, hull_health - final_damage)
	return final_damage

# Repair Minigames Logic
func start_repair_minigame(type: MinigameType) -> void:
	current_minigame = type
	minigame_progress = 0.0
	match type:
		MinigameType.HULL_BREACH:
			breach_taps_current = 0
		MinigameType.ENGINE_CALIBRATION:
			current_calibration_value = 0.0
		MinigameType.CIRCUIT_BREAKER:
			breakers_state = [false, false, false, false]

func process_hull_breach_tap() -> void:
	if current_minigame != MinigameType.HULL_BREACH:
		return
	breach_taps_current += 1
	minigame_progress = (float(breach_taps_current) / float(breach_taps_required)) * 100.0
	repair_progress_updated.emit("HULL BREACH", minigame_progress)
	if breach_taps_current >= breach_taps_required:
		_complete_minigame("HULL BREACH")

func process_engine_calibration_slider(value: float) -> void:
	if current_minigame != MinigameType.ENGINE_CALIBRATION:
		return
	current_calibration_value = value
	var diff: float = abs(value - target_calibration_value)
	if diff <= 0.05:
		minigame_progress = 100.0
		repair_progress_updated.emit("ENGINE CALIBRATION", 100.0)
		_complete_minigame("ENGINE CALIBRATION")
	else:
		minigame_progress = max(0.0, (1.0 - diff) * 100.0)
		repair_progress_updated.emit("ENGINE CALIBRATION", minigame_progress)

func toggle_circuit_breaker(index: int) -> void:
	if current_minigame != MinigameType.CIRCUIT_BREAKER or index < 0 or index >= breakers_state.size():
		return
	breakers_state[index] = not breakers_state[index]
	var all_on: bool = true
	var count_on: int = 0
	for b in breakers_state:
		if b: count_on += 1
		else: all_on = false

	minigame_progress = (float(count_on) / float(breakers_state.size())) * 100.0
	repair_progress_updated.emit("CIRCUIT BREAKER", minigame_progress)
	if all_on:
		_complete_minigame("CIRCUIT BREAKER")

func _complete_minigame(system_name: String) -> void:
	current_minigame = MinigameType.NONE
	hull_health = min(max_hull_health, hull_health + 25.0)
	system_repaired.emit(system_name)
