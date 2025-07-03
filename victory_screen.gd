extends Control

func _ready():
	self.process_mode = Node.PROCESS_MODE_WHEN_PAUSED


func _on_back_to_menu_button_pressed():
	get_tree().paused = false  # por si el juego está pausado
	get_tree().change_scene_to_file("res://menu.tscn")
	var esc_event := InputEventKey.new()
	esc_event.keycode = KEY_ESCAPE
	InputMap.action_add_event("pause", esc_event)

	
	
func online():
	$VBoxContainer/HBoxContainer/RematchButton.visible = true
	$VBoxContainer/HBoxContainer/LobbyButton.visible = true
