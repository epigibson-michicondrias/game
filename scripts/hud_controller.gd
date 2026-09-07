class_name HUDController
extends CanvasLayer

enum Role { NAVIGATOR, GUNNER, DEFENSE }

@export var sub_controller: SubmarineController
@export var weapons_system: WeaponsSystem
@export var defense_system: DefenseSystem

var current_role: Role = Role.NAVIGATOR

# Role Panels
@onready var navigator_layer: Control = $MainContainer/RoleLayers/NavigatorLayer
@onready var gunner_layer: Control = $MainContainer/RoleLayers/GunnerLayer
@onready var defense_layer: Control = $MainContainer/RoleLayers/DefenseLayer

# Top Bar & Menu Controls
@onready var btn_menu: Button = $MainContainer/TopBar/TabContainer/BtnMenu
@onready var btn_hangar: Button = $MainContainer/TopBar/TabContainer/BtnHangar
@onready var main_menu_overlay: Control = $MainContainer/MainMenuOverlay
@onready var hangar_overlay: Control = $MainContainer/HangarOverlay

@onready var btn_play_pvp: Button = $MainContainer/MainMenuOverlay/MenuContainer/BtnPlayPVP
@onready var btn_star_chart: Button = $MainContainer/MainMenuOverlay/MenuContainer/BtnStarChart
@onready var btn_hangar_menu: Button = $MainContainer/MainMenuOverlay/MenuContainer/BtnHangarMenu
@onready var btn_resume_game: Button = $MainContainer/MainMenuOverlay/MenuContainer/BtnResumeGame
@onready var btn_deploy_from_hangar: Button = $MainContainer/HangarOverlay/BtnDeployFromHangar

# Steering Drag Area
@onready var steering_touch_area: Panel = $MainContainer/RoleLayers/NavigatorLayer/SteeringTouchArea

# Role Tabs
@onready var btn_role_nav: Button = $MainContainer/TopBar/TabContainer/BtnNavigator
@onready var btn_role_gun: Button = $MainContainer/TopBar/TabContainer/BtnGunner
@onready var btn_role_def: Button = $MainContainer/TopBar/TabContainer/BtnDefense

# Navigator UI Controls
@onready var btn_gear_stop: Button = $MainContainer/RoleLayers/NavigatorLayer/GearContainer/BtnStop
@onready var btn_gear_slow: Button = $MainContainer/RoleLayers/NavigatorLayer/GearContainer/BtnSlow
@onready var btn_gear_cruise: Button = $MainContainer/RoleLayers/NavigatorLayer/GearContainer/BtnCruise
@onready var btn_gear_flank: Button = $MainContainer/RoleLayers/NavigatorLayer/GearContainer/BtnFlank
@onready var btn_gear_silent: Button = $MainContainer/RoleLayers/NavigatorLayer/GearContainer/BtnSilent
@onready var depth_slider: VSlider = $MainContainer/RoleLayers/NavigatorLayer/DepthSliderContainer/DepthSlider
@onready var lbl_telemetry_depth: Label = $MainContainer/RoleLayers/NavigatorLayer/TelemetryContainer/LblDepth
@onready var lbl_telemetry_speed: Label = $MainContainer/RoleLayers/NavigatorLayer/TelemetryContainer/LblSpeed
@onready var lbl_telemetry_decibels: Label = $MainContainer/RoleLayers/NavigatorLayer/TelemetryContainer/LblDecibels

# Gunner UI Controls
@onready var btn_weapon_1: Button = $MainContainer/RoleLayers/GunnerLayer/WeaponsContainer/BtnWeapon1
@onready var btn_weapon_2: Button = $MainContainer/RoleLayers/GunnerLayer/WeaponsContainer/BtnWeapon2
@onready var btn_weapon_3: Button = $MainContainer/RoleLayers/GunnerLayer/WeaponsContainer/BtnWeapon3
@onready var btn_skill_1: Button = $MainContainer/RoleLayers/GunnerLayer/SkillsContainer/BtnSkill1
@onready var btn_skill_2: Button = $MainContainer/RoleLayers/GunnerLayer/SkillsContainer/BtnSkill2
@onready var btn_fire_trigger: Button = $MainContainer/RoleLayers/GunnerLayer/BtnFireTrigger
@onready var crosshair_lbl: Label = $MainContainer/RoleLayers/GunnerLayer/ReticleCenter/Crosshair
@onready var lead_reticle: Control = $MainContainer/RoleLayers/GunnerLayer/ReticleCenter/LeadReticle

# Defense UI Controls
@onready var lbl_tti_counter: Label = $MainContainer/RoleLayers/DefenseLayer/RadarContainer/LblTTI
@onready var btn_evasion_order: Button = $MainContainer/RoleLayers/DefenseLayer/BtnEvasionOrder
@onready var btn_minigame_breach: Button = $MainContainer/RoleLayers/DefenseLayer/RepairPanel/BtnBreach
@onready var btn_minigame_engine: Button = $MainContainer/RoleLayers/DefenseLayer/RepairPanel/BtnEngine
@onready var btn_minigame_breaker: Button = $MainContainer/RoleLayers/DefenseLayer/RepairPanel/BtnBreaker
@onready var minigame_progress_bar: ProgressBar = $MainContainer/RoleLayers/DefenseLayer/RepairPanel/MinigameProgress

var selected_weapon_slot: int = 0
var is_touch_steering: bool = false
var touch_start_pos: Vector2 = Vector2.ZERO

func _ready() -> void:
	_connect_ui_signals()
	_connect_system_signals()
	_switch_role(Role.NAVIGATOR)

func _process(_delta: float) -> void:
	if current_role == Role.GUNNER:
		_process_gunner_targeting()

func _input(event: InputEvent) -> void:
	if steering_touch_area and steering_touch_area.visible and current_role == Role.NAVIGATOR:
		if event is InputEventMouseButton:
			var mb = event as InputEventMouseButton
			if mb.button_index == MOUSE_BUTTON_LEFT:
				var touch_rect = steering_touch_area.get_global_rect()
				if touch_rect.has_point(mb.position):
					is_touch_steering = mb.pressed
					touch_start_pos = mb.position
				else:
					if not mb.pressed:
						is_touch_steering = false
						if sub_controller:
							sub_controller.input_yaw = 0.0
							sub_controller.input_pitch = 0.0

		elif event is InputEventMouseMotion and is_touch_steering:
			var mm = event as InputEventMouseMotion
			var delta_pos = mm.position - touch_start_pos
			if sub_controller:
				sub_controller.input_yaw = clamp(delta_pos.x / 50.0, -1.0, 1.0)
				sub_controller.input_pitch = clamp(-delta_pos.y / 50.0, -1.0, 1.0)

func _connect_ui_signals() -> void:
	# Menu & Overlay Signals
	if btn_menu: btn_menu.pressed.connect(_toggle_main_menu)
	if btn_hangar: btn_hangar.pressed.connect(_toggle_hangar)
	if btn_play_pvp: btn_play_pvp.pressed.connect(_on_resume_deployment)
	if btn_star_chart: btn_star_chart.pressed.connect(_on_resume_deployment)
	if btn_hangar_menu: btn_hangar_menu.pressed.connect(_toggle_hangar)
	if btn_resume_game: btn_resume_game.pressed.connect(_on_resume_deployment)
	if btn_deploy_from_hangar: btn_deploy_from_hangar.pressed.connect(_on_resume_deployment)

	# Role Tab Signals
	if btn_role_nav: btn_role_nav.pressed.connect(func(): _switch_role(Role.NAVIGATOR))
	if btn_role_gun: btn_role_gun.pressed.connect(func(): _switch_role(Role.GUNNER))
	if btn_role_def: btn_role_def.pressed.connect(func(): _switch_role(Role.DEFENSE))

	# Navigator Gear Signals
	if btn_gear_stop: btn_gear_stop.pressed.connect(func(): _on_gear_button_pressed(SubmarineController.Gear.STOP))
	if btn_gear_slow: btn_gear_slow.pressed.connect(func(): _on_gear_button_pressed(SubmarineController.Gear.SLOW))
	if btn_gear_cruise: btn_gear_cruise.pressed.connect(func(): _on_gear_button_pressed(SubmarineController.Gear.CRUISE))
	if btn_gear_flank: btn_gear_flank.pressed.connect(func(): _on_gear_button_pressed(SubmarineController.Gear.FLANK))
	if btn_gear_silent: btn_gear_silent.pressed.connect(func(): _on_gear_button_pressed(SubmarineController.Gear.SILENT))

	if depth_slider: depth_slider.value_changed.connect(_on_depth_slider_changed)

	# Gunner Signals
	if btn_weapon_1: btn_weapon_1.pressed.connect(func(): selected_weapon_slot = 0)
	if btn_weapon_2: btn_weapon_2.pressed.connect(func(): selected_weapon_slot = 1)
	if btn_weapon_3: btn_weapon_3.pressed.connect(func(): selected_weapon_slot = 2)
	if btn_skill_1: btn_skill_1.pressed.connect(func(): if weapons_system: weapons_system.use_hull_ability(0))
	if btn_skill_2: btn_skill_2.pressed.connect(func(): if weapons_system: weapons_system.use_hull_ability(1))
	if btn_fire_trigger: btn_fire_trigger.pressed.connect(_on_fire_trigger_pressed)

	# Defense Signals
	if btn_evasion_order: btn_evasion_order.pressed.connect(_on_evasion_order_pressed)
	if btn_minigame_breach: btn_minigame_breach.pressed.connect(_on_breach_repair_pressed)
	if btn_minigame_engine: btn_minigame_engine.pressed.connect(_on_engine_calibration_pressed)
	if btn_minigame_breaker: btn_minigame_breaker.pressed.connect(_on_circuit_breaker_pressed)

func _connect_system_signals() -> void:
	if sub_controller:
		sub_controller.telemetry_updated.connect(_on_telemetry_updated)
		sub_controller.silent_running_status.connect(_on_silent_running_status)

	if weapons_system:
		weapons_system.weapon_cooldown_updated.connect(_on_weapon_cooldown_updated)
		weapons_system.target_lead_calculated.connect(_on_target_lead_calculated)

	if defense_system:
		defense_system.incoming_threat_detected.connect(_on_incoming_threat)
		defense_system.repair_progress_updated.connect(_on_repair_progress)

func _toggle_main_menu() -> void:
	if main_menu_overlay:
		main_menu_overlay.visible = not main_menu_overlay.visible
		if hangar_overlay: hangar_overlay.visible = false

func _toggle_hangar() -> void:
	if hangar_overlay:
		hangar_overlay.visible = not hangar_overlay.visible
		if main_menu_overlay: main_menu_overlay.visible = false

func _on_resume_deployment() -> void:
	if main_menu_overlay: main_menu_overlay.visible = false
	if hangar_overlay: hangar_overlay.visible = false

func _switch_role(role: Role) -> void:
	current_role = role

	if navigator_layer: navigator_layer.visible = (role == Role.NAVIGATOR)
	if gunner_layer: gunner_layer.visible = (role == Role.GUNNER)
	if defense_layer: defense_layer.visible = (role == Role.DEFENSE)

	# Switch Camera perspective on Submarine
	if sub_controller:
		var cam_chase = sub_controller.get_node_or_null("ChaseCamera") as Camera3D
		var cam_periscope = sub_controller.get_node_or_null("PeriscopeCamera") as Camera3D
		if cam_chase and cam_periscope:
			cam_chase.current = (role == Role.NAVIGATOR or role == Role.DEFENSE)
			cam_periscope.current = (role == Role.GUNNER)

func _on_gear_button_pressed(gear: SubmarineController.Gear) -> void:
	if sub_controller:
		sub_controller.set_gear(gear)

func _on_depth_slider_changed(value: float) -> void:
	if sub_controller:
		sub_controller.input_heave = (value - 50.0) / 50.0

func _on_telemetry_updated(depth: float, speed: float, decibels: float) -> void:
	if lbl_telemetry_depth: lbl_telemetry_depth.text = "DEPTH: %.1fm" % depth
	if lbl_telemetry_speed: lbl_telemetry_speed.text = "SPEED: %.1f kts" % speed
	if lbl_telemetry_decibels: lbl_telemetry_decibels.text = "NOISE: %.1f dB" % decibels

func _on_silent_running_status(active: bool, time_left: float) -> void:
	if btn_gear_silent:
		if active:
			btn_gear_silent.text = "SILENT (%.1fs)" % time_left
			btn_gear_silent.disabled = false
		elif time_left > 0.0:
			btn_gear_silent.text = "COOLDOWN (%.1fs)" % time_left
			btn_gear_silent.disabled = true
		else:
			btn_gear_silent.text = "SILENT RUNNING"
			btn_gear_silent.disabled = false

func _on_fire_trigger_pressed() -> void:
	if weapons_system:
		weapons_system.fire_weapon(selected_weapon_slot)

func _on_weapon_cooldown_updated(slot_index: int, time_left: float) -> void:
	var btn: Button = null
	match slot_index:
		0: btn = btn_weapon_1
		1: btn = btn_weapon_2
		2: btn = btn_weapon_3

	if btn:
		if time_left > 0.0:
			btn.text = "SLOT %d (%.1fs)" % [slot_index + 1, time_left]
			btn.disabled = true
		else:
			btn.text = "WEAPON %d" % [slot_index + 1]
			btn.disabled = false

func _process_gunner_targeting() -> void:
	if sub_controller == null:
		return

	var camera = sub_controller.get_node_or_null("PeriscopeCamera") as Camera3D
	if camera == null or not camera.current:
		return

	# Perform camera raycast for target lock
	var ray_origin = camera.global_transform.origin
	var ray_dir = -camera.global_transform.basis.z

	var space_state = camera.get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_origin + ray_dir * 500.0)
	query.exclude = [sub_controller.get_rid()]
	var result = space_state.intersect_ray(query)

	if result and result.get("collider") is TargetDummy:
		if crosshair_lbl:
			crosshair_lbl.text = "+ [ TARGET LOCKED ] +"
		if weapons_system:
			weapons_system.target_node = result["collider"] as Node3D
	else:
		if crosshair_lbl:
			crosshair_lbl.text = "+ [ SEARCHING ] +"

func _on_target_lead_calculated(lead_pos: Vector3, _is_stabilized: bool) -> void:
	if sub_controller == null or lead_reticle == null:
		return

	var camera = sub_controller.get_node_or_null("PeriscopeCamera") as Camera3D
	if camera and camera.current:
		if camera.is_position_behind(lead_pos):
			lead_reticle.visible = false
		else:
			var screen_pos = camera.unproject_position(lead_pos)
			lead_reticle.global_position = screen_pos
			lead_reticle.visible = true

func _on_incoming_threat(threat_id: String, tti: float) -> void:
	if lbl_tti_counter:
		lbl_tti_counter.text = "ALERT: %s | TTI: %.1fs" % [threat_id, tti]

func _on_evasion_order_pressed() -> void:
	if defense_system:
		defense_system.issue_evasion_order()

func _on_breach_repair_pressed() -> void:
	if defense_system:
		if defense_system.current_minigame != DefenseSystem.MinigameType.HULL_BREACH:
			defense_system.start_repair_minigame(DefenseSystem.MinigameType.HULL_BREACH)
		defense_system.process_hull_breach_tap()

func _on_engine_calibration_pressed() -> void:
	if defense_system:
		if defense_system.current_minigame != DefenseSystem.MinigameType.ENGINE_CALIBRATION:
			defense_system.start_repair_minigame(DefenseSystem.MinigameType.ENGINE_CALIBRATION)
		defense_system.process_engine_calibration_slider(0.75)

func _on_circuit_breaker_pressed() -> void:
	if defense_system:
		if defense_system.current_minigame != DefenseSystem.MinigameType.CIRCUIT_BREAKER:
			defense_system.start_repair_minigame(DefenseSystem.MinigameType.CIRCUIT_BREAKER)
		defense_system.toggle_circuit_breaker(0)

func _on_repair_progress(_system_name: String, progress: float) -> void:
	if minigame_progress_bar:
		minigame_progress_bar.value = progress
