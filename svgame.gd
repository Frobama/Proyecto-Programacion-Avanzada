extends Node2D

var multijugador = false
var is_bullet_hell = false
var num_mob = 0
@export var remaining_time: int = 60
@export var mob_limit: int = 10

var kills = 0
var halftime = 0
var doubled_mob_limit = false

@onready var countdown_timer = $CountdownTimer
@onready var time_label = $CanvasLayer/TimeLabel
@onready var money_label = $CanvasLayer/HBoxContainer/MoneyLabel
@onready var bullet_hell_border = $CanvasLayer/BulletHellBorder
@onready var player = $Player
@onready var gun = $Player/Gun

var chat_instance = Global.chat_instance

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
	
	if multijugador:
		for i in range(4):
			unlock_skill(i)
	# Asigna el player a todos los mobs existentes ya colocados en el editor
	for child in get_children():
		if child is Mob:
			child.player = player

	$CanvasLayer/HBoxContainer/AnimatedSprite2D.play("moneda")
	$CountdownTimer.start()
	update_timer_label()

	bullet_hell_border.visible = false

func _on_enter_bullet_hell():
	is_bullet_hell = true
	bullet_hell_border.visible = true
	#animate_bullet_hell_border()
	gun.visible = false

	var childs = get_children()
	for child in childs:
		if child is Mob:
			child.bullet_hell_mode = true

func _on_exit_bullet_hell():
	is_bullet_hell = false
	bullet_hell_border.visible = false
	gun.visible = true

	var childs = get_children()
	for child in childs:
		if child is Mob:
			child.bullet_hell_mode = false

#opcional
func animate_bullet_hell_border():
	var tween = create_tween().set_loops()
	tween.tween_property(bullet_hell_border, "modulate:a", 0.1, 2.0).set_trans(Tween.TRANS_SINE)
	tween.tween_property(bullet_hell_border, "modulate:a", 0.4, 2.0).set_trans(Tween.TRANS_SINE)

func mob_time_progression():
	if remaining_time <= halftime and not doubled_mob_limit:
		print("Mitad del tiempo alcanzada: ", remaining_time)
		mob_limit = mob_limit * 2
		doubled_mob_limit = true
		print("Nuevo límite de mobs: ", mob_limit)

func spawn_mob():
	if num_mob < mob_limit:
		var new_mob = preload("res://mob.tscn").instantiate()
		new_mob.connect("death", Callable(self, "mob_death"))
		%PathFollow2D.progress_ratio = randf()
		new_mob.global_position = %PathFollow2D.global_position

		var player = get_node_or_null("Player")
		if player:
			new_mob.player = player
		else:
			print("No se encontró al jugador para asignarlo al mob")

		add_child(new_mob)
		num_mob += 1

func mob_death():
	num_mob -= 1
	
	if not multijugador:
		kills+=1
		check_unlock_skills()
		

func check_unlock_skills():
	match kills:
		5:
			unlock_skill(0)
		10:
			unlock_skill(1)
		15:
			unlock_skill(2)
		25:
			unlock_skill(3)
			
func unlock_skill(index):
	var player = get_node("Player")
	var skill_bar = player.get_node("UI/SkillBar")
	var slots = skill_bar.get_slots()
	
	match index:
		0:
			slots[0].is_unlocked = true
			slots[0].change_key = '1'
			if not multijugador:
				player.nuevaSkill("Explosión Química")
		1:
			slots[1].is_unlocked = true
			slots[1].change_key = "2"
			if not multijugador:
				player.nuevaSkill("Llamado de las Aves")
		2: 
			slots[2].is_unlocked = true
			slots[2].change_key = "3"
			if not multijugador:
				player.nuevaSkill("Terremoto")
		3:
			slots[3].is_unlocked = true
			slots[3].change_key = "4"
			if not multijugador:
				player.nuevaSkill("Botiquín")
			
func _on_timer_timeout():
	if not is_bullet_hell:
		spawn_mob()
	mob_time_progression()

var not_sent = true
func _on_player_health_depleted():
	if chat_instance and multijugador and not_sent:
		not_sent = false
		chat_instance._send_death()
		print("muerte enviada")
		await get_tree().create_timer(0.01).timeout
	var scene = preload("res://GameOver.tscn")
	var game_over = scene.instantiate()
	if multijugador:
		game_over.online()
		
	game_over.connect("rematch", Callable(self, "_send_rematch"))
	game_over.connect("lobby", Callable(self, "_lobby"))
	game_over.connect("quit", Callable(self, "_quit_online"))
	
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
	if multijugador:
		victory.online()
		
	victory.connect("rematch", Callable(self, "_send_rematch"))
	victory.connect("lobby", Callable(self, "_lobby"))
	victory.connect("quit", Callable(self, "_quit_online"))
	var ui_layer = CanvasLayer.new()
	ui_layer.layer = 1
	ui_layer.add_child(victory)

	add_child(ui_layer)

	victory.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	await get_tree().create_timer(0.01).timeout
	get_tree().paused = true
	
	


func _surrender():
	if chat_instance:
		chat_instance._send_surrender()
		_quit_online()
		
func _quit_online():
	if chat_instance:
		chat_instance._send_quit_match()
		var boton = chat_instance.get_node("VBoxContainer/MainPanel/VBoxContainer/StartGameButton")
		boton.visible = true
		boton = chat_instance.get_node("VBoxContainer/MainPanel/VBoxContainer/CancelGameButton")
		boton.visible = false
		
func _send_rematch():
	if chat_instance:
		chat_instance._send_rematch_request()
			
func _lobby():
	if chat_instance:
		chat_instance._send_quit_match()
	queue_free()
	chat_instance.visible = true
	var boton = chat_instance.get_node("VBoxContainer/MainPanel/VBoxContainer/StartGameButton")
	boton.visible = true
	boton = chat_instance.get_node("VBoxContainer/MainPanel/VBoxContainer/CancelGameButton")
	boton.visible = false
	
	get_tree().paused = false
		

func _on_CountdownTimer_timeout():
	remaining_time -= 1
	update_timer_label()

	if remaining_time <= 0:
		$CountdownTimer.stop()
		show_victory_screen()

func _on_player_money_change(cantidad) -> void:
	money_label.text = "Dinero: $" + str(cantidad)
	var player = get_node("Player")
	if player.money >= 5:
		var arma = get_node("Player/Gun")
		arma.type = 2
	if player.money >= 15 and multijugador:
		enviar_buff_enemigos()

func apply_remote_event(data):
	match data.subEvent:
		"attack":
			recibir_ataque(data.attack_data)
		"death":
			chat_instance.on_opponent_defeated()
		"surrender":
			chat_instance.on_opponent_defeated()

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
			$Player.mostrar_mensaje_ataque("Aumento de vida de los enemigos")
			
			
func is_multiplayer():
	return multijugador
