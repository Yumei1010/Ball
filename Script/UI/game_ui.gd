extends Control

@onready var score_label := $ScoreLabel as Label
@onready var high_score_label := $HighScoreLabel as Label
@onready var combo_label := $ComboLabel as Label
@onready var speed_value_label := get_node_or_null("HBoxContainer/SpeedValue") as Label
@onready var game_timer_label := get_node_or_null("GameTimerLabel") as Label
@onready var energy_bar_1 := get_node_or_null("BoxContainer/EnergyBar1") as TextureProgressBar
@onready var energy_bar_2 := get_node_or_null("BoxContainer/EnergyBar2") as TextureProgressBar
@onready var energy_bar_3 := get_node_or_null("BoxContainer/EnergyBar3") as TextureProgressBar
@onready var effect_bar1_full := get_node_or_null("BoxContainer/EnergyBar1_FullEffect") as AnimatedSprite2D
@onready var effect_bar2_full := get_node_or_null("BoxContainer/EnergyBar2_FullEffect") as AnimatedSprite2D
@onready var effect_bar3_full := get_node_or_null("BoxContainer/EnergyBar3_FullEffect") as AnimatedSprite2D
@onready var launch_fail_effect := get_node_or_null("BoxContainer/LaunchFailEffect") as AnimatedSprite2D
@onready var combo_lost_anim := get_node_or_null("ComboLostAnimationPlayer") as AnimationPlayer
@onready var danger_flash := get_node_or_null("DangerFlash") as ColorRect

var displayed_score: float = 0.0
var score_tween: Tween


func _ready() -> void:
	high_score_label.text = "High Score: %d" % DataManager.high_score
	effect_bar1_full.animation_finished.connect(effect_bar1_full.hide)
	effect_bar2_full.animation_finished.connect(effect_bar2_full.hide)
	effect_bar3_full.animation_finished.connect(effect_bar3_full.hide)
	effect_bar1_full.visible = false
	effect_bar2_full.visible = false
	effect_bar3_full.visible = false


func _process(_delta: float) -> void:
	score_label.text = "%d" % int(displayed_score)


func on_score_updated(new_score: int) -> void:
	if is_instance_valid(score_tween):
		score_tween.kill()
	score_tween = create_tween()
	score_tween.tween_method(_set_displayed_score, displayed_score, float(new_score), 0.3)
	if new_score > DataManager.high_score:
		high_score_label.modulate = Color("00ffff")
	else:
		high_score_label.modulate = Color("ff3b30")


func _set_displayed_score(value: float) -> void:
	displayed_score = value


func update_game_timer(new_time_float: float) -> void:
	game_timer_label.text = "%.2fs" % new_time_float


func update_speed_label(new_speed: float) -> void:
	var normalized_speed: float = new_speed / 10.0
	speed_value_label.text = "%.0f" % normalized_speed
	var progress: float = clamp(normalized_speed / 400.0, 0.0, 1.0)
	speed_value_label.modulate = lerp(Color.WHITE, Color("ff3b30"), progress)
	speed_value_label.scale = lerp(Vector2.ONE, Vector2(1.5, 1.5), progress)
	toggle_danger_overlay(new_speed < 1500.0)


func update_energy_display(total_energy: float) -> void:
	energy_bar_1.value = min(total_energy, 100.0)
	energy_bar_2.value = clamp(total_energy - 100.0, 0.0, 100.0)
	energy_bar_3.value = clamp(total_energy - 200.0, 0.0, 100.0)


func play_bar1_full_animation() -> void:
	effect_bar1_full.visible = true
	effect_bar1_full.play("play_full_effect")


func play_bar2_full_animation() -> void:
	effect_bar2_full.visible = true
	effect_bar2_full.play("play_full_effect")


func play_bar3_full_animation() -> void:
	effect_bar3_full.visible = true
	effect_bar3_full.play("play_full_effect")


func on_player_launch_failed() -> void:
	launch_fail_effect.visible = true
	launch_fail_effect.play("flash")


func on_combo_updated(combo_count: int) -> void:
	if combo_count > 0:
		combo_label.text = "x%d" % combo_count
		combo_label.visible = true
		var tween := create_tween()
		tween.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
		tween.tween_property(combo_label, "scale", Vector2(1.3, 1.3), 0.2)
		tween.tween_property(combo_label, "scale", Vector2.ONE, 0.2)
	else:
		var tween := create_tween()
		tween.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
		tween.tween_property(combo_label, "scale", Vector2(0.7, 0.7), 0.1)
		tween.tween_property(combo_label, "scale", Vector2.ONE, 0.1)
		tween.tween_callback(func(): combo_label.visible = false)


func on_combo_lost() -> void:
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "modulate", Color.RED, 0.1)
	tween.tween_property(self, "modulate", Color.WHITE, 0.1)


func toggle_danger_overlay(is_dangerous: bool) -> void:
	var target_alpha: float = 0.3 if is_dangerous else 0.0
	var tween := create_tween()
	tween.tween_property(danger_flash, "modulate:a", target_alpha, 0.2)
