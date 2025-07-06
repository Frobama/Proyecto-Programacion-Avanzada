extends Button
var sonidoFondo = preload("res://songs/ObservingTheStar.ogg")

func _ready():
	BocinaPrincipal.stream = sonidoFondo
	BocinaPrincipal.stream.loop = true
	BocinaPrincipal.play()
func _on_pressed() -> void:
	get_tree().change_scene_to_file("res://levels.tscn")


func _on_op_pressed() -> void:
	get_tree().change_scene_to_file("res://opcion.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_multi_pressed() -> void:
	var scene = preload("res://chat-window.tscn")
	var instance = scene.instantiate()
	Global.chat_instance = instance
	get_tree().change_scene_to_file("res://chat-window.tscn")
