extends CanvasLayer


func _ready() -> void:
	%ResumeButton.pressed.connect(_on_resume)
	%MainMenuButton.pressed.connect(_on_main_menu)


func _on_resume() -> void:
	get_tree().paused = false


func _on_main_menu() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scene/main_menu.tscn")
