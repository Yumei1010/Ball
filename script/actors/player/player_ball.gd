extends RigidBody2D

signal speed_updated(speed: float)
signal energy_updated(current_energy: float)
signal combo_updated(combo_count: int)
signal combo_lost()
signal launch_failed()
signal wall_bounced(bounce_count: int, is_combo_lost: bool, impact_position: Vector2)
signal enemy_killed()
signal energy_bar_1_filled()
signal energy_bar_2_filled()
signal energy_bar_3_filled()
signal player_died()

const MAX_ENERGY := 300.0
const LAUNCH_ENERGY_COST := 100.0
const CAMERA_SHAKE_STRENGTH := 6.0
const MIN_LAUNCH_SPEED := 800.0

@export_group("Launch Power", "launch_")
@export var launch_multiplier: float = 10.0
@export var kill_threshold: float = 1500.0
@export var default_max_speed: float = 4000.0
@export var slow_mo_scale: float = 0.1

@export_group("Energy System")
@export var energy_per_kill: float = 28.0
@export var energy_per_bounce: float = 35.0
@export var energy_drain_per_second: float = 80.0

@export_group("Combo System")
@export var combo_max_bounces: int = 4
@export var combo_speed_bonus: float = 250.0
@export var combo_energy_bonus: float = 12.0

@onready var line_2d: Line2D = $Line2D
@onready var kill_area: Area2D = $Area2D
@onready var death_audio_player: AudioStreamPlayer = $DeathAudioPlayer
@onready var visual_sprite: Sprite2D = $Sprite2D
@onready var trail_node: Line2D = $TrailwithLine2D
@onready var slow_mo_audio: AudioStreamPlayer = $SlowMoAudioPlayer
@onready var launch_audio: AudioStreamPlayer = $LaunchAudioPlayer
@onready var cancel_audio: AudioStreamPlayer = $CancelAudioPlayer
@onready var death_effect: ColorRect = get_node_or_null("/root/Main_tscn/DeathInversionEffect")
@onready var spawner: Node = get_node_or_null("/root/Main_tscn/EnemySpawner")
@onready var camera: Camera2D = get_node_or_null("/root/Main_tscn/Camera2D")

var is_dead: bool = false
var is_aiming: bool = false
var current_energy: float = MAX_ENERGY
var drag_start_position_screen: Vector2 = Vector2.ZERO
var velocity_before_impact: Vector2 = Vector2.ZERO
var current_combo: int = 0
var bounces_since_last_kill: int = 0
var has_killed_in_combo: bool = false
var current_max_speed: float = 0.0
var line_color_normal: Color = Color.WHITE
var line_color_low_energy: Color = Color("ff3b30")
var line_color_tween: Tween
var camera_zoom_tween: Tween

func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 5
	sleeping = false
	kill_area.area_entered.connect(_on_kill_area_entered)
	current_max_speed = default_max_speed
	speed_updated.connect(on_speed_updated)

func _input(event: InputEvent) -> void:
	if is_dead: return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.is_pressed():
		_cancel_aiming()
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			if not is_aiming:
				is_aiming = true
				Engine.time_scale = slow_mo_scale
				drag_start_position_screen = event.position
				line_2d.clear_points()
				line_2d.add_point(Vector2.ZERO)
				line_2d.add_point(Vector2.ZERO)
				if is_instance_valid(slow_mo_audio):
					slow_mo_audio.play()
				tween_camera_zoom(Vector2(1.05, 1.15), 0.2)
		else:
			if not is_aiming: return
			is_aiming = false
			Engine.time_scale = 1.0
			line_2d.clear_points()
			if is_instance_valid(slow_mo_audio):
				slow_mo_audio.stop()
			tween_camera_zoom(Vector2(1.0, 1.0), 0.2)

			if current_energy < LAUNCH_ENERGY_COST:
				if is_instance_valid(cancel_audio):
					cancel_audio.play()
				launch_failed.emit()
				return

			if is_instance_valid(launch_audio):
				launch_audio.play()

			_update_energy(current_energy - LAUNCH_ENERGY_COST)

			var screen_drag_vector: Vector2 = event.position - drag_start_position_screen
			var launch_magnitude: float = screen_drag_vector.length() * launch_multiplier
			launch_magnitude = maxf(launch_magnitude, MIN_LAUNCH_SPEED)
			var mouse_world_pos: Vector2 = get_global_mouse_position()
			var world_direction: Vector2 = (mouse_world_pos - global_position).normalized()
			if world_direction == Vector2.ZERO: world_direction = Vector2.UP
			linear_velocity = -world_direction * launch_magnitude

			var is_fast_enough: bool = linear_velocity.length_squared() > kill_threshold * kill_threshold
			set_collision_mask_value(2, not is_fast_enough)


func tween_camera_zoom(target_zoom: Vector2, duration: float = 0.2) -> void:
	if not is_instance_valid(camera): return
	if is_instance_valid(camera_zoom_tween):
		camera_zoom_tween.kill()
	camera_zoom_tween = create_tween()
	camera_zoom_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	camera_zoom_tween.tween_property(camera, "zoom", target_zoom, duration)

func _process(delta: float) -> void:
	if not is_aiming: return

	var mouse_world_pos: Vector2 = get_global_mouse_position()
	var local_mouse_pos: Vector2 = to_local(mouse_world_pos)
	line_2d.set_point_position(1, local_mouse_pos)

	_update_energy(current_energy - (energy_drain_per_second * delta))

	if current_energy <= 0.0:
		_cancel_aiming()
		return

	if current_energy < LAUNCH_ENERGY_COST:
		_tween_line_color(line_color_low_energy)
	else:
		_tween_line_color(line_color_normal)

func _physics_process(_delta: float) -> void:
	velocity_before_impact = linear_velocity

	if not is_aiming and linear_velocity.length_squared() < 1.0 and not get_collision_mask_value(2):
		set_collision_mask_value(2, true)

	if linear_velocity.length() > current_max_speed:
		linear_velocity = linear_velocity.normalized() * current_max_speed

	speed_updated.emit(int(linear_velocity.length()))

func _cancel_aiming() -> void:
	if not is_aiming: return
	is_aiming = false
	Engine.time_scale = 1.0
	line_2d.clear_points()
	if is_instance_valid(slow_mo_audio): slow_mo_audio.stop()
	if is_instance_valid(cancel_audio): cancel_audio.play()
	tween_camera_zoom(Vector2(1.0, 1.0), 0.2)

func on_speed_updated(current_speed: float) -> void:
	if is_instance_valid(visual_sprite):
		visual_sprite.modulate = get_color_for_speed(current_speed)

func get_color_for_speed(speed: float) -> Color:
	var low_thresh: float = trail_node.low_speed_threshold
	var high_thresh: float = trail_node.high_speed_threshold

	if speed <= low_thresh:
		return trail_node.low_speed_color
	elif speed < high_thresh:
		var progress: float = inverse_lerp(low_thresh, high_thresh, speed)
		return trail_node.low_speed_color.lerp(trail_node.mid_speed_color, progress)
	else:
		var super_speed_thresh: float = high_thresh + 500.0
		var progress: float = inverse_lerp(high_thresh, super_speed_thresh, speed)
		return trail_node.mid_speed_color.lerp(trail_node.high_speed_color, progress)

func _update_energy(new_energy: float) -> void:
	var energy_before: float = current_energy
	current_energy = clamp(new_energy, 0.0, MAX_ENERGY)
	energy_updated.emit(current_energy)

	if current_energy <= energy_before: return

	if energy_before < 100.0 and current_energy >= 100.0:
		energy_bar_1_filled.emit()
	if energy_before < 200.0 and current_energy >= 200.0:
		energy_bar_2_filled.emit()
	if energy_before < MAX_ENERGY and current_energy >= MAX_ENERGY:
		energy_bar_3_filled.emit()

func _on_kill_area_entered(area: Area2D) -> void:
	if is_dead: return
	var enemy_body: Node = area.owner
	if not enemy_body: return
	if velocity_before_impact.length_squared() <= kill_threshold * kill_threshold: return
	if not enemy_body.is_in_group("enemy"): return

	var impact_direction: Vector2 = velocity_before_impact.normalized()
	enemy_body.die(impact_direction)
	call_deferred("trigger_kill_slow_motion", 0.15, 0.2)
	enemy_killed.emit()

	if is_instance_valid(camera):
		camera.apply_shake(CAMERA_SHAKE_STRENGTH)

	bounces_since_last_kill = 0

	current_combo += 1
	combo_updated.emit(current_combo)
	current_max_speed = default_max_speed + (current_combo * combo_speed_bonus)

	_update_energy(current_energy + combo_energy_bonus)
	_update_energy(current_energy + energy_per_kill)

	if is_instance_valid(spawner):
		spawner.add_score(enemy_body.base_score_value, current_combo, enemy_body.global_position)

func _on_body_entered(body: Node) -> void:
	if is_dead: return

	var cs: CollisionShape2D = $CollisionShape2D
	if not cs.shape: return
	var player_radius: float = cs.shape.radius * global_scale.x
	var impact_direction: Vector2 = velocity_before_impact.normalized()
	var impact_position: Vector2 = global_position + impact_direction * player_radius

	if body.is_in_group("enemy"):
		if velocity_before_impact.length_squared() < kill_threshold * kill_threshold:
			_player_death_sequence()
		return

	if body.is_in_group("bouncing_enemy"): return

	var is_combo_lost_this_hit: bool = false
	if not has_killed_in_combo:
		bounces_since_last_kill += 1
		if bounces_since_last_kill >= combo_max_bounces:
			is_combo_lost_this_hit = true

	wall_bounced.emit(bounces_since_last_kill, is_combo_lost_this_hit, impact_position)

	if is_combo_lost_this_hit:
		lose_combo()

	_update_energy(current_energy + energy_per_bounce)

func lose_combo() -> void:
	if current_combo <= 0: return
	current_combo = 0
	combo_updated.emit(current_combo)
	combo_lost.emit()
	current_max_speed = default_max_speed
	bounces_since_last_kill = 0

func trigger_kill_slow_motion(duration: float, time_scale_during_slow_mo: float = 0.2) -> void:
	Engine.time_scale = time_scale_during_slow_mo
	await get_tree().create_timer(duration, true, false, true).timeout
	Engine.time_scale = slow_mo_scale if is_aiming else 1.0

func _tween_line_color(target_color: Color) -> void:
	if line_2d.default_color == target_color: return
	if is_instance_valid(line_color_tween):
		line_color_tween.kill()
	line_color_tween = create_tween()
	line_color_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	line_color_tween.tween_property(line_2d, "default_color", target_color, 0.003)

func _player_death_sequence() -> void:
	if is_dead: return
	is_dead = true

	if MusicManager:
		MusicManager.stop_immediately()

	player_died.emit()

	if is_instance_valid(death_audio_player):
		death_audio_player.play()

	lose_combo()

	Engine.time_scale = 1.0
	get_tree().paused = true

	var tween: Tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.set_trans(Tween.TRANS_SINE)

	if is_instance_valid(death_effect):
		tween.tween_property(death_effect, "modulate:a", 1.0, 0.3)
		tween.tween_interval(0.4)
		tween.tween_property(death_effect, "modulate:a", 0.0, 0.3)
		death_effect.show()
		await tween.finished
		death_effect.hide()

	get_tree().paused = false
	get_tree().reload_current_scene()
