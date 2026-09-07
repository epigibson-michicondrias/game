class_name Torpedo
extends Area3D

signal exploded(position: Vector3)

@export var speed: float = 40.0
@export var damage: float = 100.0
@export var lifetime: float = 10.0
@export var homing_strength: float = 0.5

var launcher_node: Node3D = null
var target_node: Node3D = null
var velocity: Vector3 = Vector3.ZERO
var lifetime_timer: float = 0.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	velocity = -global_transform.basis.z * speed

func _process(delta: float) -> void:
	lifetime_timer += delta
	if lifetime_timer >= lifetime:
		_explode()
		return

	if target_node != null and is_instance_valid(target_node):
		var target_dir = (target_node.global_transform.origin - global_transform.origin).normalized()
		var current_dir = velocity.normalized()
		var new_dir = current_dir.slerp(target_dir, homing_strength * delta).normalized()
		velocity = new_dir * speed
		look_at(global_transform.origin + velocity, Vector3.UP)

	global_transform.origin += velocity * delta

func _on_body_entered(body: Node3D) -> void:
	if body == launcher_node or body == owner:
		return
	if body.has_method("take_damage"):
		body.take_damage(damage)
	_explode()

func _on_area_entered(area: Area3D) -> void:
	if area.owner == launcher_node or area == launcher_node:
		return
	if area.has_method("take_damage"):
		area.take_damage(damage)
		_explode()

func _explode() -> void:
	exploded.emit(global_transform.origin)
	queue_free()
