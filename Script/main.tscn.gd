extends Node

const BATTLE_BGM := preload("res://assets/Audio/Music/Neon Ghosts.mp3")

var _death_pause := false


func _ready() -> void:
	var player: RigidBody2D = $PlayerBall
	var game_ui: Control = $GameUI
	var spawner: Node = $EnemySpawner

	player.energy_updated.connect(game_ui.update_energy_display)
	player.combo_updated.connect(game_ui.on_combo_updated)
	player.combo_lost.connect(game_ui.on_combo_lost)
	spawner.game_time_updated.connect(game_ui.update_game_timer)
	spawner.score_updated.connect(game_ui.on_score_updated)
	player.energy_bar_1_filled.connect(game_ui.play_bar1_full_animation)
	player.energy_bar_2_filled.connect(game_ui.play_bar2_full_animation)
	player.energy_bar_3_filled.connect(game_ui.play_bar3_full_animation)
	player.launch_failed.connect(game_ui.on_player_launch_failed)
	player.player_died.connect(_on_player_died)

	var bounce_mgr: Node = $BounceCounterManager
	player.wall_bounced.connect(bounce_mgr.on_player_wall_bounced)
	player.enemy_killed.connect(bounce_mgr.on_player_killed_enemy)
	player.combo_lost.connect(bounce_mgr.on_player_combo_lost)

	MusicManager.crossfade_to(BATTLE_BGM, 1.5)


func _input(_event: InputEvent) -> void:
	if _death_pause: return
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().paused = not get_tree().paused


func _process(_delta: float) -> void:
	$PauseMenu.visible = get_tree().paused and not _death_pause


func _on_player_died() -> void:
	_death_pause = true
