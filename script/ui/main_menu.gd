extends Control

const DEFAULT_GAME_SCENE := "res://scene/main.tscn"

@export_file var game_scene_path: String = DEFAULT_GAME_SCENE


func _on_start() -> void:
	get_tree().change_scene_to_file(game_scene_path if game_scene_path else DEFAULT_GAME_SCENE)

func _on_quit() -> void:
	get_tree().quit()
