extends Control


func _on_exit_pressed() -> void:
	get_tree().change_scene_to_file("res://menu.tscn")


func _on_level_1_pressed() -> void:
	var game = preload("res://svgame.tscn").instantiate()
	
	game.remaining_time = 45
	game.mob_limit = 8
	get_tree().root.add_child(game)
	get_tree().current_scene.queue_free()
	get_tree().current_scene = game
	


func _on_level_2_pressed() -> void:
	var game = preload("res://svgame.tscn").instantiate()
	
	game.remaining_time = 75
	game.mob_limit = 10
	get_tree().root.add_child(game)
	get_tree().current_scene.queue_free()
	get_tree().current_scene = game


func _on_level_3_pressed() -> void:
	var game = preload("res://svgame.tscn").instantiate()
	
	game.remaining_time = 90
	game.mob_limit = 11
	get_tree().root.add_child(game)
	get_tree().current_scene.queue_free()
	get_tree().current_scene = game


func _on_level_4_pressed() -> void:
	var game = preload("res://svgame.tscn").instantiate()
	
	game.remaining_time = 105
	game.mob_limit = 12
	get_tree().root.add_child(game)
	get_tree().current_scene.queue_free()
	get_tree().current_scene = game


func _on_level_5_pressed() -> void:
	var game = preload("res://svgame.tscn").instantiate()
	
	game.remaining_time = 120
	game.mob_limit = 13
	get_tree().root.add_child(game)
	get_tree().current_scene.queue_free()
	get_tree().current_scene = game
