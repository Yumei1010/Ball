extends Control

@onready var high_score_value: Label = %HighScoreValue
@onready var total_time_value: Label = %TotalTimeValue
@onready var total_kills_value: Label = %TotalKillsValue
@onready var max_kills_value: Label = %MaxKillsValue
@onready var max_combo_value: Label = %MaxComboValue
@onready var back_button: Button = %BackButton
@onready var max_time_value: Label = %MaxTimeValue

func _ready() -> void:
	back_button.pressed.connect(queue_free)
	
	high_score_value.text = str(DataManager.high_score)
	total_time_value.text = format_time(DataManager.total_play_time)
	total_kills_value.text = str(DataManager.total_kills)
	max_kills_value.text = str(DataManager.max_kills_per_run)
	max_combo_value.text = str(DataManager.max_combo_per_run)
	max_time_value.text = format_time(DataManager.max_survival_time)

func format_time(time_in_seconds: float) -> String:
	var formatted_seconds = "%.2f" % time_in_seconds
	return formatted_seconds + "s"
