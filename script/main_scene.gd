extends Node

const BATTLE_BGM := preload("res://assets/audio/Music/Neon Ghosts.mp3")

@onready var player: RigidBody2D = $PlayerBall
@onready var game_ui: Control = $GameUI
@onready var spawner: Node = $EnemySpawner
@onready var bounce_counter_manager: Node = $BounceCounterManager
@onready var pause_menu: Node = $PauseMenu

var _death_pause := false

func _ready() -> void:
	player.energy_updated.connect(game_ui.update_energy_display)
	player.combo_updated.connect(game_ui.on_combo_updated)
	player.combo_lost.connect(game_ui.on_combo_lost)
	spawner.game_time_updated.connect(game_ui.update_game_timer)
	spawner.score_updated.connect(game_ui.on_score_updated)
	player.player_died.connect(_on_player_died)
	player.wall_bounced.connect(bounce_counter_manager.on_player_wall_bounced)
	player.enemy_killed.connect(bounce_counter_manager.on_player_killed_enemy)
	player.combo_lost.connect(bounce_counter_manager.on_player_combo_lost)
	MusicManager.crossfade_to(BATTLE_BGM, 1.5)

func _input(_event: InputEvent) -> void:
	if _death_pause: return
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().paused = not get_tree().paused

func _process(_delta: float) -> void:
	pause_menu.visible = get_tree().paused and not _death_pause

func _on_player_died() -> void:
	_death_pause = true
