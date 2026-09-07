class_name HydrothermalVent
extends Area3D

@export var damage_per_second: float = 15.0
@export var plume_height: float = 10.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

var overlapping_subs: Array[SubmarineController] = []

func _on_body_entered(body: Node3D) -> void:
	if body is SubmarineController:
		overlapping_subs.append(body as SubmarineController)

func _on_body_exited(body: Node3D) -> void:
	if body is SubmarineController:
		overlapping_subs.erase(body as SubmarineController)

func _process(delta: float) -> void:
	for sub in overlapping_subs:
		var def_sys = sub.get_node_or_null("DefenseSystem") as DefenseSystem
		if def_sys:
			def_sys.apply_damage(damage_per_second * delta, sub)
