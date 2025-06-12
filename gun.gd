extends Area2D

var type = 1#Pistola normal
#tipo 2: Escopeta (?)
#tipo 3: rifle (dispara mas rapido)
var puede_disparar = true

@onready var sound_pistol = $SFX_pistola

func shoot():
	if not puede_disparar:
		return
		
	if type == 1:
		$"../TimerDisparo".wait_time = 0.6
		const BULLET = preload("res://bullet.tscn")
		var new_bullet = BULLET.instantiate()
		new_bullet.global_position = %ShootingPart.global_position
		
		# Calcular dirección en base a rotación del ShootingPart
		var angle = %ShootingPart.global_rotation
		new_bullet.rotation = angle  # opcional, para que la sprite de la bala se oriente
		new_bullet.direction = Vector2.RIGHT.rotated(angle)
		new_bullet.is_enemy_bullet = false
		new_bullet.shooter = self
		new_bullet.get_node("Projectile").modulate = Color("e54b4af2")
		get_tree().current_scene.add_child(new_bullet)
		sound_pistol.play()
		puede_disparar = false
		$"../TimerDisparo".start()
	
	if type == 2:
		$"../TimerDisparo".wait_time = 0.6
		const BULLET = preload("res://bullet.tscn")
		var new_bullet = BULLET.instantiate()
		var new_bullet2 = BULLET.instantiate()
		var new_bullet3 = BULLET.instantiate()
		new_bullet.global_position = %ShootingPart.global_position
		new_bullet2.global_position = %ShootingPart.global_position
		new_bullet3.global_position = %ShootingPart.global_position
		
		
		#Bala 1
		# Calcular dirección en base a rotación del ShootingPart
		var angle = %ShootingPart.global_rotation
		new_bullet.rotation = angle  # opcional, para que la sprite de la bala se oriente
		new_bullet.direction = Vector2.RIGHT.rotated(angle)
		new_bullet.is_enemy_bullet = false
		new_bullet.shooter = self
		new_bullet.get_node("Projectile").modulate = Color("e54b4af2")
		
		#Bala 2
		angle = %ShootingPart.global_rotation + 0.3
		new_bullet2.rotation = angle  # opcional, para que la sprite de la bala se oriente
		new_bullet2.direction = Vector2.RIGHT.rotated(angle)
		new_bullet2.is_enemy_bullet = false
		new_bullet2.shooter = self
		new_bullet2.get_node("Projectile").modulate = Color("e54b4af2")
		
		#Bala 3
		angle = %ShootingPart.global_rotation - 0.3
		new_bullet3.rotation = angle  # opcional, para que la sprite de la bala se oriente
		new_bullet3.direction = Vector2.RIGHT.rotated(angle)
		new_bullet3.is_enemy_bullet = false
		new_bullet3.shooter = self
		new_bullet3.get_node("Projectile").modulate = Color("e54b4af2")
		
		sound_pistol.play()
		get_tree().current_scene.add_child(new_bullet)
		get_tree().current_scene.add_child(new_bullet2)
		get_tree().current_scene.add_child(new_bullet3)
		puede_disparar = false
		$"../TimerDisparo".start()
	if type == 3:
		$"../TimerDisparo".wait_time = 0.05
		const BULLET = preload("res://bullet.tscn")
		var new_bullet = BULLET.instantiate()
		new_bullet.global_position = %ShootingPart.global_position
		
		# Calcular dirección en base a rotación del ShootingPart
		var angle = %ShootingPart.global_rotation
		new_bullet.rotation = angle  # opcional, para que la sprite de la bala se oriente
		new_bullet.direction = Vector2.RIGHT.rotated(angle)
		new_bullet.is_enemy_bullet = false
		new_bullet.shooter = self
		new_bullet.get_node("Projectile").modulate = Color("e54b4af2")
		get_tree().current_scene.add_child(new_bullet)
		puede_disparar = false
		$"../TimerDisparo".start()
		

func _on_timer_disparo_timeout() -> void:
	puede_disparar = true
