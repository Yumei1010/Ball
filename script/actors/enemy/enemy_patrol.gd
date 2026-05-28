extends RigidBody2D

@export var KILL_EFFECT := preload("res://scene/effect/kill_effect.tscn")

@export_group("Movement")
@export var move_speed: float = 350.0
@export var turn_rate: float = 5.0

@export_group("Scoring")
@export var base_score_value: int = 130

var assigned_path: Path2D
var path_manager: Node
var path_points: PackedVector2Array = []
var current_target_index: int = 1

func initialize(path: Path2D, manager: Node) -> void:
	assigned_path = path
	path_manager = manager

	if not assigned_path.curve:
		return

	var curve: Curve2D = assigned_path.curve
	path_points.resize(curve.point_count)
	for i: int in range(curve.point_count):
		path_points[i] = assigned_path.to_global(curve.get_point_position(i))

	if path_points.size() < 2:
		set_physics_process(false)
		return

	global_position = path_points[0]

func _physics_process(delta: float) -> void:
	if path_points.size() < 2: return

	var target: Vector2 = path_points[current_target_index]
	var dir: Vector2 = (target - global_position).normalized()
	linear_velocity = dir * move_speed

	var target_angle: float = dir.angle() + PI / 2.0
	rotation = lerp_angle(rotation, target_angle, turn_rate * delta)

	if global_position.distance_to(target) < 10.0:
		current_target_index += 1
		if current_target_index >= path_points.size():
			path_points.reverse()
			current_target_index = 1

func die(impact_direction: Vector2) -> void:
	if is_instance_valid(path_manager):
		path_manager.release_path(assigned_path)

	var effect: Node = KILL_EFFECT.instantiate()
	effect.rotation = impact_direction.angle() + PI / 2.0
	effect.global_position = global_position
	get_parent().add_child(effect)
	queue_free()
