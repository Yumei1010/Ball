extends RigidBody2D

@export var kill_effect_scene: PackedScene

@export_group("Scoring")
@export var base_score_value: int = 100


func die(impact_direction: Vector2) -> void:
	if not kill_effect_scene: return
	var effect := kill_effect_scene.instantiate()
	effect.rotation = impact_direction.angle() + PI / 2.0
	effect.global_position = global_position
	get_parent().add_child(effect)
	queue_free()
