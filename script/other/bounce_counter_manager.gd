extends Node

# Audio-only wall bounce manager. Visual counters removed with deleted assets.
@export var base_pitch: float = 1.2
@export var pitch_decrement: float = 0.2
@export var combo_lost_pitch: float = 0.5


func _ready() -> void:
	pass


func on_player_wall_bounced(bounce_count: int, is_combo_lost: bool, _impact_position: Vector2) -> void:
	var player := $WallBouncePlayer as AudioStreamPlayer
	if not player: return
	player.pitch_scale = combo_lost_pitch if is_combo_lost else maxf(base_pitch - (bounce_count - 1) * pitch_decrement, 0.1)
	player.play()


func on_player_killed_enemy() -> void:
	pass


func on_player_combo_lost() -> void:
	pass
