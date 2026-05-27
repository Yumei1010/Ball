extends Control

const GAME_SCENE := "res://scene/main.tscn"

func _on_start() -> void:
	get_tree().change_scene_to_file(GAME_SCENE)

func _on_quit() -> void:
	get_tree().quit()
