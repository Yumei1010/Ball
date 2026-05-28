extends Node

const SAVE_FILE_PATH := "user://savegame.dat"

var high_score: int = 0
var has_played_before: bool = false
var settings: Dictionary = {
	fullscreen = false,
	language = "en",
	music_volume = 50.0,
	sfx_volume = 50.0,
}
var total_play_time: float = 0.0
var total_kills: int = 0
var max_kills_per_run: int = 0
var max_combo_per_run: int = 0
var max_survival_time: float = 0.0


func apply_all_settings() -> void:
	TranslationServer.set_locale(settings.language)
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Music"),
		linear_to_db(settings.music_volume / 100.0)
	)
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("SFX"),
		linear_to_db(settings.sfx_volume / 100.0)
	)


func _ready() -> void:
	var os_lang: String = OS.get_locale_language()
	settings.language = "zh" if os_lang == "zh" else "en"
	load_data()
	apply_all_settings()


func load_data() -> void:
	if not FileAccess.file_exists(SAVE_FILE_PATH): return
	var file: FileAccess = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	var data = file.get_var(true)
	file.close()
	if not (data is Dictionary): return
	high_score = data.get("high_score", 0)
	var saved_settings: Dictionary = data.get("settings", {})
	for key in saved_settings:
		settings[key] = saved_settings[key]
	has_played_before = data.get("has_played_before", false)
	total_play_time = data.get("total_play_time", 0.0)
	total_kills = data.get("total_kills", 0)
	max_kills_per_run = data.get("max_kills_per_run", 0)
	max_combo_per_run = data.get("max_combo_per_run", 0)
	max_survival_time = data.get("max_survival_time", 0.0)


func save_data() -> void:
	var file: FileAccess = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	file.store_var({
		high_score = high_score,
		settings = settings,
		has_played_before = has_played_before,
		total_play_time = total_play_time,
		total_kills = total_kills,
		max_kills_per_run = max_kills_per_run,
		max_combo_per_run = max_combo_per_run,
		max_survival_time = max_survival_time,
	}, true)
	file.close()


func report_new_score(score: int) -> void:
	if score > high_score:
		high_score = score
		save_data()


func set_played_before() -> void:
	if not has_played_before:
		has_played_before = true
		save_data()


func toggle_fullscreen() -> void:
	settings.fullscreen = not settings.fullscreen
	apply_all_settings()
	save_data()


func debug_reset_all_data() -> void:
	high_score = 0
	total_play_time = 0.0
	total_kills = 0
	max_kills_per_run = 0
	max_combo_per_run = 0
	max_survival_time = 0.0
	has_played_before = false
	settings.language = "zh" if OS.get_locale_language() == "zh" else "en"
	settings.fullscreen = false
	settings.music_volume = 50.0
	settings.sfx_volume = 50.0
	apply_all_settings()
	save_data()
	get_tree().reload_current_scene()


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("debug_reset"):
		debug_reset_all_data()
