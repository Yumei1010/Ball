extends Control

@onready var score_label: Label = $ScoreLabel
@onready var high_score_label: Label = $HighScoreLabel
@onready var combo_label: Label = $ComboLabel
@onready var game_timer_label: Label = $GameTimerLabel
@onready var energy_bar_1: TextureProgressBar = $BoxContainer/EnergyBar as TextureProgressBar
@onready var energy_bar_2: TextureProgressBar = $BoxContainer/EnergyBar2 as TextureProgressBar
@onready var energy_bar_3: TextureProgressBar = $BoxContainer/EnergyBar3 as TextureProgressBar

var _displayed_score: float = 0.0

func _ready() -> void:
	high_score_label.text = "High Score: %d" % DataManager.high_score

func _process(_delta: float) -> void:
	score_label.text = "%d" % int(_displayed_score)

func on_score_updated(new_score: int) -> void:
	var tween: Tween = create_tween()
	tween.tween_method(func(v: float): _displayed_score = v, _displayed_score, float(new_score), 0.3)

func update_game_timer(new_time_float: float) -> void:
	game_timer_label.text = "%.2fs" % new_time_float

func update_speed_label(_new_speed: float) -> void: pass

func update_energy_display(total_energy: float) -> void:
	energy_bar_1.value = minf(total_energy, 100.0)
	energy_bar_2.value = clampf(total_energy - 100.0, 0.0, 100.0)
	energy_bar_3.value = clampf(total_energy - 200.0, 0.0, 100.0)

func on_combo_updated(combo_count: int) -> void:
	combo_label.text = "x%d" % combo_count
	combo_label.visible = combo_count > 0

func on_combo_lost() -> void:
	combo_label.visible = false
