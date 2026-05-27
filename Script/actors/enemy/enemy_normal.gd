extends RigidBody2D

const KILL_EFFECT := preload("res://game/effect/kill_effect.tscn")

@export_group("Scoring")
@export var base_score_value: int = 100


func die(impact_direction: Vector2) -> void:
	var effect := KILL_EFFECT.instantiate()
	effect.rotation = impact_direction.angle() + PI / 2.0
	effect.global_position = global_position
	get_parent().add_child(effect)
	queue_free()
