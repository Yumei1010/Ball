extends Node

const BATTLE_BGM = preload("res://assets/Audio/Music/Neon Ghosts.mp3")

var time_scale_before_pause: float = 1.0
var is_paused: bool = false
var is_death_pause_active: bool = false

# 用 @onready 获取节点引用
@onready var player: RigidBody2D = $PlayerBall
@onready var game_ui: Control = $GameUI
@onready var spawner: Node = $EnemySpawner
@onready var background_effects: AnimatedSprite2D = $BackgroundEffects
@onready var audio_manager: Node = $AudioManager
@onready var bounce_counter_manager: Node = $BounceCounterManager
@onready var pause_menu: CanvasLayer = $PauseMenu



func _ready() -> void:
	#if MusicManager:
		#MusicManager.play()

	# 连接信号！
	player.speed_updated.connect(game_ui.update_speed_label)
	player.energy_updated.connect(game_ui.update_energy_display)
	player.combo_updated.connect(game_ui.on_combo_updated)
	player.combo_lost.connect(game_ui.on_combo_lost)
	spawner.game_time_updated.connect(game_ui.update_game_timer)
	spawner.score_updated.connect(game_ui.on_score_updated)
	player.combo_lost.connect(background_effects.play_combo_lost_effect)
	player.wall_bounced.connect(func(_b: int, _c: bool, _p: Vector2): background_effects.play_bounce_effect())
	player.energy_bar_1_filled.connect(game_ui.play_bar1_full_animation)
	player.energy_bar_2_filled.connect(game_ui.play_bar2_full_animation)
	player.energy_bar_3_filled.connect(game_ui.play_bar3_full_animation)
	player.launch_failed.connect(game_ui.on_player_launch_failed)
	player.wall_bounced.connect(bounce_counter_manager.on_player_wall_bounced)
	player.enemy_killed.connect(bounce_counter_manager.on_player_killed_enemy)
	player.combo_lost.connect(bounce_counter_manager.on_player_combo_lost)
	player.player_died.connect(on_player_died)

	# 告诉全局管理器：平滑过渡到战斗音乐
	MusicManager.crossfade_to(BATTLE_BGM, 1.5)



func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().paused = not get_tree().paused


func _process(_delta: float) -> void:
	# --- 【核心修正】在这里加入状态检查 ---
	# 只有在【不是】死亡暂停的情况下，才根据 paused 状态显示菜单
	if not is_death_pause_active:
		pause_menu.visible = get_tree().paused



func toggle_pause_menu() -> void:
	# 1. 直接反转游戏树的暂停状态
	get_tree().paused = not get_tree().paused
	
	# 2. 根据新的暂停状态，来决定是否显示菜单
	pause_menu.visible = get_tree().paused




func toggle_fullscreen_mode() -> void:
	# 我们只做一件事：切换窗口的全屏状态
	# get_window().mode 这个属性，是 Godot 4 中控制窗口模式最直接的方法
	
	if get_window().mode == Window.MODE_FULLSCREEN:
		# 如果当前是全屏，就切换回窗口
		get_window().mode = Window.MODE_WINDOWED
		print("已退出全屏。")
	else:
		# 如果当前不是全屏，就切换到全屏
		get_window().mode = Window.MODE_FULLSCREEN
		print("已进入全屏。")



# --- 【新增】一个专门接收死亡信号的函数 ---
func on_player_died() -> void:
	# 当收到玩家死亡的信号时，立刻”上锁”
	is_death_pause_active = true
