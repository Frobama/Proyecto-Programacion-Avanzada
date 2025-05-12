extends Node2D


<<<<<<< Updated upstream
=======
func _ready() -> void:
	var player = get_node("Player")
	player.connect("request_bullet_hell", Callable(self, "_on_enter_bullet_hell"))
	player.connect("request_bullet_hell_end", Callable(self, "_on_exit_bullet_hell"))
	
	#asigna el player a todos los mobs existentes ya colocados en el editor desde antes
	for child in get_children():
		if child is Mob:
			child.player = player
				
func _on_enter_bullet_hell():
	is_bullet_hell = true
	var childs = get_children()
	
	for child in childs:
		if child is Mob:
			child.bullet_hell_mode = true
	
func _on_exit_bullet_hell():
	is_bullet_hell = false
	
	var childs = get_children()
	
	for child in childs:
		if child is Mob:
			child.bullet_hell_mode = false
	
>>>>>>> Stashed changes
func spawn_mob():
	var new_mob = preload("res://mob.tscn").instantiate()
	var player_node = get_node_or_null("Player")

	if player_node == null:
		print("no se encontro al player en svgame.tscn")
	else:
		new_mob.player = player_node
		
	%PathFollow2D.progress_ratio = randf()
	new_mob.global_position = %PathFollow2D.global_position
	add_child(new_mob)


func _on_timer_timeout():
	spawn_mob()
