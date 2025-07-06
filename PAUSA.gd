extends CanvasLayer

var player_alive = true

func _physics_process(delta: float):
	if player_alive:
		if Input.is_action_just_pressed("pause"):
			var escena = get_tree().current_scene
			if escena.has_method("is_multiplayer") and not escena.is_multiplayer():
				get_tree().paused = not get_tree().paused
			$ColorRect.visible = not $ColorRect.visible
			$Label.visible = not $Label.visible
			$Salir.visible = not $Salir.visible

func _on_salir_pressed():
	get_tree().paused = false
	var escena = get_tree().current_scene
	if escena.has_method("is_multiplayer") and escena.is_multiplayer():
		escena._surrender()
		
		if Global.chat_instance != null:
			Global.chat_instance.queue_free()
			Global.chat_instance = null
			
	get_tree().change_scene_to_file("res://menu.tscn")


func _on_opcion_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://opcion.tscn")


func _on_player_health_depleted() -> void:
	player_alive = false
	
