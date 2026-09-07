class_name TargetDummy
extends CharacterBody3D

signal destroyed()
signal health_changed(current: float, max_health: float)

@export var max_health: float = 500.0
@export var speed: float = 8.0
@export var waypoints: Array[Vector3] = [
	Vector3(-100, -30, -100),
	Vector3(100, -30, -100),
	Vector3(100, -30, 100),
	Vector3(-100, -30, 100)
]

var current_health: float = 500.0
var current_waypoint_index: int = 0
var is_dead: bool = false
var respawn_timer: float = 0.0
const RESPAWN_DELAY: float = 10.0

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D

func _ready() -> void:
	current_health = max_health

func _physics_process(delta: float) -> void:
	if is_dead:
		respawn_timer -= delta
		if respawn_timer <= 0.0:
			_respawn()
		return

	_process_patrol(delta)

func _process_patrol(delta: float) -> void:
	if waypoints.is_empty():
		return

	var target_pos = waypoints[current_waypoint_index]
	var dir = (target_pos - global_transform.origin)
	dir.y = 0 # Maintain level depth for patrol

	if dir.length() < 3.0:
		current_waypoint_index = (current_waypoint_index + 1) % waypoints.size()
		return

	dir = dir.normalized()
	velocity = dir * speed
	look_at(global_transform.origin + dir, Vector3.UP)
	move_and_slide()

func take_damage(amount: float) -> void:
	if is_dead:
		return

	current_health = max(0.0, current_health - amount)
	health_changed.emit(current_health, max_health)
	_flash_hit()

	if current_health <= 0.0:
		_die()

func _flash_hit() -> void:
	if mesh_instance:
		mesh_instance.visible = false
		await get_tree().create_timer(0.1).timeout
		if is_instance_valid(mesh_instance):
			mesh_instance.visible = true

func _die() -> void:
	is_dead = true
	visible = false
	collision_layer = 0
	collision_mask = 0
	respawn_timer = RESPAWN_DELAY
	destroyed.emit()

func _respawn() -> void:
	is_dead = false
	visible = true
	collision_layer = 1
	collision_mask = 1
	current_health = max_health
	health_changed.emit(current_health, max_health)
