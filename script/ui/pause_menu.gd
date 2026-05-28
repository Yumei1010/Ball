extends CanvasLayer

@export_file var main_menu_scene_path: String


func _on_resume_button_click() -> void:
	get_tree().paused = false


func _on_main_menu_button_click() -> void:
	get_tree().paused = false
	if main_menu_scene_path: get_tree().change_scene_to_file(main_menu_scene_path)
