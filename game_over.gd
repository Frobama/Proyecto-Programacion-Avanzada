extends Control

signal rematch
signal lobby
signal quit

func _ready():
	print("Muerto")
	self.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	$VBoxContainer/Button.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	$VBoxContainer/Button2.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	
	$VBoxContainer/Button.pressed.connect(_on_retry_button_pressed)
	$VBoxContainer/Button2.pressed.connect(_on_exit_button_pressed)
	
func _on_retry_button_pressed():
	print("retry")
	get_tree().paused = false
	get_tree().change_scene_to_file("res://levels.tscn")
	
func _on_exit_button_pressed():
	print("exit")
	get_tree().paused = false
	
	if Global.chat_instance != null:
		Global.chat_instance.queue_free()
		Global.chat_instance = null

	get_tree().change_scene_to_file("res://menu.tscn")
	quit.emit()


func online():
	$VBoxContainer/Button.visible = false
	$VBoxContainer/RematchButton.visible = true
	$VBoxContainer/LobbyButton.visible = true


func _on_rematch_button_pressed() -> void:
	rematch.emit()


func _on_lobby_button_pressed() -> void:
	lobby.emit()
