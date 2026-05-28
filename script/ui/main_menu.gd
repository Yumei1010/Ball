extends Control

@export_file var game_scene_path: String

func _on_start() -> void:
	if game_scene_path: get_tree().change_scene_to_file(game_scene_path)

func _on_quit() -> void:
	get_tree().quit()
