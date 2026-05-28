extends Node

@onready var hover_player: AudioStreamPlayer = $HoverPlayer
@onready var click_player: AudioStreamPlayer = $ClickPlayer


func _ready() -> void:
	get_tree().node_added.connect(on_node_added)
	call_deferred("scan_existing_buttons")


func on_node_added(node: Node) -> void:
	if node is Button:
		connect_button_sounds(node)


func scan_existing_buttons() -> void:
	var buttons: Array[Node] = get_tree().get_nodes_in_group("buttons")
	for item in buttons:
		var btn: Button = item as Button
		if btn:
			connect_button_sounds(btn)


func connect_button_sounds(button: Button) -> void:
	if not button.is_in_group("buttons"):
		return
	if not button.mouse_entered.is_connected(play_hover_sound):
		button.mouse_entered.connect(play_hover_sound)
	if not button.pressed.is_connected(play_click_sound):
		button.pressed.connect(play_click_sound)


func play_hover_sound() -> void:
	hover_player.play()


func play_click_sound() -> void:
	click_player.play()
