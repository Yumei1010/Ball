extends CanvasLayer

func _on_resume_button_click() -> void:
	get_tree().paused = false

func _on_main_menu_button_click() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scene/main_menu.tscn")
