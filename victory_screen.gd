extends Control

signal rematch
signal lobby
signal quit

func _ready():
	self.process_mode = Node.PROCESS_MODE_WHEN_PAUSED


func _on_back_to_menu_button_pressed():
	get_tree().paused = false  # por si el juego está pausado
	
	if Global.chat_instance != null:
		Global.chat_instance.queue_free()
		Global.chat_instance = null
		
	get_tree().change_scene_to_file("res://menu.tscn")
	var esc_event := InputEventKey.new()
	esc_event.keycode = KEY_ESCAPE
	InputMap.action_add_event("pause", esc_event)
	quit.emit()
	
	
func online():
	$VBoxContainer/HBoxContainer/RematchButton.visible = true
	$VBoxContainer/HBoxContainer/LobbyButton.visible = true


func _on_rematch_button_pressed() -> void:
	rematch.emit()
	

func _on_lobby_button_pressed() -> void:
	var esc_event := InputEventKey.new()
	esc_event.keycode = KEY_ESCAPE
	InputMap.action_add_event("pause", esc_event)
	lobby.emit()
