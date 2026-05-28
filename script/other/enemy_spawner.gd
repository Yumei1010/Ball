extends Node

signal game_time_updated(time_float: float)
signal score_updated(new_score: int)

@export var spawn_zone_path: NodePath
@export var min_spawn_distance: float = 200.0
@export var spawn_prep_time: float = 1.0

@export var enemy_normal_scene: PackedScene = preload("res://scene/actors/enemy/enemy_normal.tscn")
@export var enemy_tracker_scene: PackedScene = preload("res://scene/actors/enemy/enemy_tracker.tscn")
@export var enemy_patrol_scene: PackedScene = preload("res://scene/actors/enemy/enemy_patrol.tscn")
@export var spawn_marker_scene: PackedScene = preload("res://scene/effect/spawn_marker.tscn")
@export var floating_text_scene: PackedScene = preload("res://scene/effect/floating_text.tscn")
@export_file var spawn_waves_path: String = "res://spawn_waves.json"

@onready var path_manager: Node = get_node_or_null("/root/Main_tscn/PathManager")
@onready var spawn_timer: Timer = $SpawnTimer
@onready var spawn_zone: Area2D = get_node_or_null(spawn_zone_path) if spawn_zone_path else null
@onready var spawn_zone_shape: CollisionShape2D = spawn_zone.get_child(0) if spawn_zone else null
@onready var player: RigidBody2D = get_node_or_null("/root/Main_tscn/PlayerBall")

var _enemy_scenes: Dictionary = {}
var current_score: int = 0
var kills_this_run: int = 0
var game_time: float = 0.0
var wave_data: Array = []
var current_wave: Dictionary


func _ready() -> void:
	_enemy_scenes = {
		"EnemyNormal": enemy_normal_scene,
		"EnemyTracker": enemy_tracker_scene,
		"EnemyPatrol": enemy_patrol_scene,
	}

	var file := FileAccess.open(spawn_waves_path, FileAccess.READ)
	if not file:
		push_error("enemy_spawner: Cannot open spawn_waves.json")
		return
	var json_data = JSON.parse_string(file.get_as_text())
	file.close()
	if json_data == null or not json_data.has("waves"):
		push_error("enemy_spawner: Invalid spawn_waves.json")
		return
	wave_data = json_data.waves

	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	_update_wave()

	if is_instance_valid(player):
		player.player_died.connect(on_player_died)

	kills_this_run = 0


func _process(delta: float) -> void:
	game_time += delta
	game_time_updated.emit(game_time)

	if game_time > current_wave.end_time and wave_data.size() > 1:
		wave_data.pop_front()
		_update_wave()

	_check_and_spawn()


func add_score(base_score: int, combo: int, position: Vector2) -> void:
	var combo_multiplier: float = 1.0 + min(0.05 * combo, 1.0)
	var final_score := int(base_score * combo_multiplier)
	current_score += final_score
	kills_this_run += 1

	if combo > DataManager.max_combo_per_run:
		DataManager.max_combo_per_run = combo
	if current_score > DataManager.high_score:
		pass

	DataManager.report_new_score(current_score)
	score_updated.emit(current_score)

	var ft := floating_text_scene.instantiate()
	get_parent().add_child(ft)
	ft.global_position = position
	ft.setup(final_score)


func _update_wave() -> void:
	if wave_data.is_empty():
		set_process(false)
		return
	current_wave = wave_data[0]
	_check_and_spawn()


func _check_and_spawn() -> void:
	if not spawn_timer.is_stopped(): return

	var count := get_tree().get_nodes_in_group("enemy").size()
	if count < current_wave.min_enemies or count < current_wave.max_enemies:
		var interval := randf_range(current_wave.min_interval, current_wave.max_interval)
		spawn_timer.wait_time = interval
		spawn_timer.start()


func _on_spawn_timer_timeout() -> void:
	var count := get_tree().get_nodes_in_group("enemy").size()
	if count >= current_wave.max_enemies: return

	var enemy_name := _pick_enemy_from_pool()
	var enemy_scene: PackedScene = _enemy_scenes[enemy_name]

	var spawn_pos: Vector2
	var patrol_path: Path2D

	if enemy_name == "EnemyPatrol":
		patrol_path = path_manager.request_free_path()
		if not patrol_path:
			enemy_name = "EnemyNormal"
			enemy_scene = _enemy_scenes["EnemyNormal"]
			spawn_pos = _find_safe_spawn_position()
		else:
			spawn_pos = patrol_path.curve.get_point_position(0)
			spawn_pos = patrol_path.to_global(spawn_pos)
			if not _is_position_safe(spawn_pos):
				path_manager.release_path(patrol_path)
				return
	else:
		spawn_pos = _find_safe_spawn_position()

	if spawn_pos == Vector2.INF:
		if patrol_path:
			path_manager.release_path(patrol_path)
		return

	var marker := spawn_marker_scene.instantiate()
	get_parent().add_child(marker)
	marker.global_position = spawn_pos
	marker.spawn_duration = spawn_prep_time
	marker.enemy_scene = enemy_scene
	marker.spawn_position = spawn_pos

	if patrol_path:
		marker.patrol_path_to_assign = patrol_path
		marker.path_manager_ref = path_manager


func _is_position_safe(pos_to_check: Vector2) -> bool:
	for enemy: Node2D in get_tree().get_nodes_in_group("enemy"):
		if enemy.global_position.distance_to(pos_to_check) < min_spawn_distance:
			return false
	return true


func _pick_enemy_from_pool() -> String:
	var rand_val := randf()
	var cumulative := 0.0
	for enemy_name: String in current_wave.enemy_pool:
		cumulative += current_wave.enemy_pool[enemy_name]
		if rand_val < cumulative:
			return enemy_name
	return ""


func _find_safe_spawn_position() -> Vector2:
	if not spawn_zone_shape: return Vector2.INF
	var spawn_shape_resource := spawn_zone_shape.shape
	var local_rect := spawn_shape_resource.get_rect()

	for _i: int in range(20):
		var local_pos := Vector2(
			randf_range(local_rect.position.x, local_rect.end.x),
			randf_range(local_rect.position.y, local_rect.end.y)
		)
		var world_pos := spawn_zone.to_global(local_pos)
		if _is_position_safe(world_pos):
			return world_pos

	return Vector2.INF


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_reset"):
		DataManager.high_score = 0
		DataManager.save_data()
		get_tree().reload_current_scene()


func on_player_died() -> void:
	DataManager.total_play_time += game_time
	DataManager.total_kills += kills_this_run
	if kills_this_run > DataManager.max_kills_per_run:
		DataManager.max_kills_per_run = kills_this_run
	if game_time > DataManager.max_survival_time:
		DataManager.max_survival_time = game_time
	DataManager.save_data()
