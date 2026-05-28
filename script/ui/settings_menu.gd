extends Control

@onready var back_button: Button = %BackButton
@onready var fullscreen_button: Button = %FullscreenButton
@onready var tutorial_button: Button = %TutorialButton
@onready var english_button: Button = %EnglishButton
@onready var chinese_button: Button = %ChineseButton
@onready var music_slider: HSlider = %MusicSlider
@onready var sfx_slider: HSlider = %SFXSlider
@onready var tutorial_image: TextureRect = %TutorialImage

func _ready() -> void:
	fullscreen_button.button_pressed = DataManager.settings.fullscreen
	music_slider.value = DataManager.settings.music_volume
	sfx_slider.value = DataManager.settings.sfx_volume
	back_button.pressed.connect(on_back_button_pressed)

	tutorial_button.pressed.connect(on_tutorial_button_pressed)
	tutorial_image.gui_input.connect(on_tutorial_image_clicked)
	fullscreen_button.pressed.connect(on_fullscreen_button_pressed)
	english_button.pressed.connect(func(): set_language("en"))
	chinese_button.pressed.connect(func(): set_language("zh"))
	music_slider.value_changed.connect(on_music_volume_changed)
	sfx_slider.value_changed.connect(on_sfx_volume_changed)

	back_button.add_to_group("buttons")
	fullscreen_button.add_to_group("buttons")
	tutorial_button.add_to_group("buttons")
	english_button.add_to_group("buttons")
	chinese_button.add_to_group("buttons")

func on_tutorial_button_pressed() -> void:
	tutorial_image.show()
	
func on_tutorial_image_clicked(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		tutorial_image.hide()

func on_fullscreen_button_pressed() -> void:
	var current_mode = DisplayServer.window_get_mode()
	if current_mode == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		get_window().move_to_center()
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	var _new_mode: DisplayServer.WindowMode = DisplayServer.window_get_mode()

func set_language(lang_code: String) -> void:
	DataManager.settings.language = lang_code
	DataManager.apply_all_settings()
	DataManager.save_data()
	get_tree().reload_current_scene()

func on_music_volume_changed(value: float) -> void:
	DataManager.settings.music_volume = value
	var music_bus_idx = AudioServer.get_bus_index("Music")
	AudioServer.set_bus_volume_db(music_bus_idx, linear_to_db(value / 100.0))
	DataManager.save_data()

func on_sfx_volume_changed(value: float) -> void:
	DataManager.settings.sfx_volume = value
	var sfx_bus_idx = AudioServer.get_bus_index("SFX")
	AudioServer.set_bus_volume_db(sfx_bus_idx, linear_to_db(value / 100.0))
	DataManager.save_data()
	
func on_back_button_pressed() -> void:
	hide()
