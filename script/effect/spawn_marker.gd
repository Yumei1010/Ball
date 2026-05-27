extends Node2D

var spawn_duration: float = 1.0
var enemy_scene: PackedScene
var spawn_position: Vector2
var patrol_path_to_assign: Path2D
var path_manager_ref: Node


func _ready() -> void:
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 1.0, spawn_duration)
	tween.finished.connect(_on_marker_ready)


func _on_marker_ready() -> void:
	if not enemy_scene: return

	var enemy: Node2D = enemy_scene.instantiate()
	enemy.global_position = spawn_position

	if patrol_path_to_assign and enemy.has_method("initialize"):
		enemy.initialize(patrol_path_to_assign, path_manager_ref)

	get_parent().add_child(enemy)
	queue_free()
