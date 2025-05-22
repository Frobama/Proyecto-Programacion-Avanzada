extends Button
var sonidoFondo = preload("res://songs/ObservingTheStar.ogg")

func _ready():
	BocinaPrincipal.stream = sonidoFondo
	BocinaPrincipal.play()
func _on_pressed() -> void:
	get_tree().change_scene_to_file("res://levels.tscn")


func _on_op_pressed() -> void:
	get_tree().change_scene_to_file("res://opcion.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()
