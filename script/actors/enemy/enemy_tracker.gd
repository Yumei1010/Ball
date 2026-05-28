extends RigidBody2D

@export var KILL_EFFECT := preload("res://scene/effect/kill_effect.tscn")

@export_group("Movement")
@export var move_speed: float = 200.0
@export var turn_rate: float = 5.0

@export_group("Scoring")
@export var base_score_value: int = 125

@onready var update_timer: Timer = $UpdateTimer

var player: Node2D
var move_direction: Vector2 = Vector2.DOWN


func _ready() -> void:
	player = get_tree().root.find_child("PlayerBall", true, false)


func _physics_process(delta: float) -> void:
	linear_velocity = move_direction * move_speed
	var target_angle: float = move_direction.angle() + PI / 2.0
	rotation = lerp_angle(rotation, target_angle, turn_rate * delta)


func _on_update_timer_timeout() -> void:
	if not is_instance_valid(player):
		move_direction = Vector2.ZERO
		return
	move_direction = (player.global_position - global_position).normalized()


func die(impact_direction: Vector2) -> void:
	var effect := KILL_EFFECT.instantiate()
	effect.rotation = impact_direction.angle() + PI / 2.0
	effect.global_position = global_position
	get_parent().add_child(effect)
	queue_free()
