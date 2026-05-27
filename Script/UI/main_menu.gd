extends Control

const GAME_SCENE := "res://Scene/Main.tscn.tscn"


func _ready() -> void:
	$VBoxContainer/StartButton.pressed.connect(_on_start)
	$VBoxContainer/QuitButton.pressed.connect(_on_quit)


func _on_start() -> void:
	get_tree().change_scene_to_file(GAME_SCENE)


func _on_quit() -> void:
	get_tree().quit()
