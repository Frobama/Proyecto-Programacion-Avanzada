extends Node2D

var is_bullet_hell = false
var num_mob = 0
var remaining_time = 60 #duracion del nivel en segundos

@onready var countdown_timer = $CountdownTimer
@onready var time_label = $CanvasLayer/TimeLabel

func _ready() -> void:
	var player = get_node("Player")
	player.connect("request_bullet_hell", Callable(self, "_on_enter_bullet_hell"))
	player.connect("request_bullet_hell_end", Callable(self, "_on_exit_bullet_hell"))
	player.connect("health_depleted", Callable(self, "_on_player_health_depleted"))
	#asigna el player a todos los mobs existentes ya colocados en el editor desde antes
	for child in get_children():
		if child is Mob:
			child.player = player
	
	$CountdownTimer.start()
	update_timer_label()
	
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
	
func spawn_mob():
	if(num_mob < 10):
		var new_mob = preload("res://mob.tscn").instantiate()
		new_mob.connect("death", Callable(self, "mob_death"))
		%PathFollow2D.progress_ratio = randf()
		new_mob.global_position = %PathFollow2D.global_position
		
		#asignar el jugador al mob spawneado
		var player = get_node_or_null("Player")
		if player:
			new_mob.player = player
		else:
			print("no se encontró al jugador para asignarlo al mob")
		
		add_child(new_mob)
		num_mob += 1

func mob_death():
	num_mob -= 1
		
func _on_timer_timeout():
	if not is_bullet_hell:
		spawn_mob()


func _on_player_health_depleted():
	var scene = preload("res://GameOver.tscn")
	var game_over = scene.instantiate()

	var ui_layer = CanvasLayer.new()
	ui_layer.layer = 1
	ui_layer.add_child(game_over)

	add_child(ui_layer)

	
	game_over.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	
	await get_tree().create_timer(0.01).timeout
	get_tree().paused = true

func update_timer_label():
	var minutes = remaining_time / 60
	var seconds = remaining_time % 60
	time_label.text = "Tiempo: %02d:%02d" % [minutes, seconds]

func show_victory_screen():
	var scene = preload("res://VictoryScreen.tscn")
	var victory = scene.instantiate()

	var ui_layer = CanvasLayer.new()
	ui_layer.layer = 1
	ui_layer.add_child(victory)

	add_child(ui_layer)

	victory.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	
	await get_tree().create_timer(0.01).timeout
	get_tree().paused = true


func _on_CountdownTimer_timeout():
	print("Timer funcionando")
	remaining_time -= 1
	update_timer_label()

	if remaining_time <= 0:
		$CountdownTimer.stop()
		show_victory_screen()
