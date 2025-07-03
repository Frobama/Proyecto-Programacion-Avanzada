extends Control

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
	get_tree().change_scene_to_file("res://menu.tscn")

func online():
	$VBoxContainer/Button.visible = false
	$VBoxContainer/RematchButton.visible = true
	$VBoxContainer/LobbyButton.visible = true
