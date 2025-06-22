extends Node2D

var multijugador = false
var is_bullet_hell = false
var num_mob = 0
@export var remaining_time: int = 60  # Tiempo variable entre niveles, cambiar desde el inspector
@export var mob_limit: int = 10  # Número máximo de mobs editable en cada nivel, cambiar desde el inspector

var halftime = 0  # inicialmente 0, se actualizará al inicio
var doubled_mob_limit = false  # Bandera para saber si ya duplicamos el límite de mobs


@onready var countdown_timer = $CountdownTimer
@onready var time_label = $CanvasLayer/TimeLabel
@onready var money_label = $CanvasLayer/HBoxContainer/MoneyLabel

var chat_instance: Node = null


func _ready() -> void:
	if chat_instance != null:
		chat_instance.svgame_instance = self
	BocinaPrincipal.stream = preload("res://songs/OST1.ogg")
	BocinaPrincipal.stream.loop = true
	BocinaPrincipal.play()
	halftime = remaining_time / 2
	
	var player = get_node("Player")
	player.connect("request_bullet_hell", Callable(self, "_on_enter_bullet_hell"))
	player.connect("request_bullet_hell_end", Callable(self, "_on_exit_bullet_hell"))
	player.connect("health_depleted", Callable(self, "_on_player_health_depleted"))
	
	# Asigna el player a todos los mobs existentes ya colocados en el editor
	for child in get_children():
		if child is Mob:
			child.player = player
	
	$CanvasLayer/HBoxContainer/AnimatedSprite2D.play("moneda")
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

func mob_time_progression():
	if remaining_time <= halftime and not doubled_mob_limit:
		print("Mitad del tiempo alcanzada: ", remaining_time)
		mob_limit = mob_limit * 2  # Duplica el límite de mobs
		doubled_mob_limit = true  # Marca que ya se duplicó el límite
		print("Nuevo límite de mobs: ", mob_limit)

func spawn_mob():
	if num_mob < mob_limit:
		var new_mob = preload("res://mob.tscn").instantiate()
		new_mob.connect("death", Callable(self, "mob_death"))
		%PathFollow2D.progress_ratio = randf()
		new_mob.global_position = %PathFollow2D.global_position
		
		# Asignar el jugador al mob spawneado
		var player = get_node_or_null("Player")
		if player:
			new_mob.player = player
		else:
			print("No se encontró al jugador para asignarlo al mob")
		
		add_child(new_mob)
		num_mob += 1

func mob_death():
	num_mob -= 1

func _on_timer_timeout():
	if not is_bullet_hell:
		spawn_mob()
	mob_time_progression()  # Actualiza la progresión de los mobs

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
	remaining_time -= 1
	update_timer_label()

	if remaining_time <= 0:
		$CountdownTimer.stop()
		show_victory_screen()

func _on_player_money_change(cantidad) -> void:
	money_label.text = "Dinero: $" + str(cantidad)
	var player = get_node("Player")
	if player.money > 5:
		var arma = get_node("Player/Gun")
		arma.type = 2
	if player.money >= 15 and multijugador:
		enviar_buff_enemigos()

func enviar_buff_enemigos():
	var player = get_node("Player")
	if player.money >= 10:
		player.add_money(-10)
		chat_instance.send_attack({
			"type": "buff_enemigos",
			"duration": "10",
			"extra_health": 3
		})
		
func recibir_ataque(data):
	match data.type:
		"buff_enemigos":
			var childs = get_children()
			for child in childs:
				if child is Mob:
					child.health += data.extra_health
					
