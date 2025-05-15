class_name Mob
extends CharacterBody2D

var health = 3
signal death

const enemy_bullet_scene = preload("res://bullet.tscn")
var shoot_timer := 0.0
var shoot_interval := 0.5

var player: CharacterBody2D = null
	
var bullet_hell_mode = false

var rotation_speed = 1.0 # Velocidad de rotación angular (radianes/segundo)
var orbit_radius = 100.0 # Distancia del mob al jugador
var orbit_angle = 0.0 # Ángulo actual del mob alrededor del jugador

var esta_muriendo = false

func _ready():
	%Slime.play_walk()
	%Slime/Anchor/SlimeBody.animation_finished.connect(_on_slime_animation_finished)
	
func _physics_process(delta):
	if player == null:
		return
		
	if not bullet_hell_mode and not esta_muriendo:
		var direction = global_position.direction_to(player.global_position)
		velocity = direction * 300.0
		move_and_slide()
		
	elif not bullet_hell_mode and esta_muriendo:
		var direction = global_position.direction_to(player.global_position)
		velocity = direction * 100.0
		move_and_slide()
		
	else:
		# Calcular el vector desde el jugador al mob
		var to_mob = global_position - player.global_position

		# Asegurar que tiene la distancia deseada
		var current_distance = to_mob.length()
		var desired_distance = 600.0  # Puedes ajustar este valor

		if abs(current_distance - desired_distance) > 10:
			# Moverse radialmente hacia la distancia deseada de forma suave
			var radial_direction = to_mob.normalized()
			var radial_speed = 50.0  # Velocidad de alejamiento/acercamiento
			velocity = radial_direction * ((desired_distance - current_distance) * 2.0)
			move_and_slide()
		else:
			# Calcular vector tangente (rotación 90°)
			var tangent = Vector2(-to_mob.y, to_mob.x).normalized()

		# Moverse tangencialmente
			var speed = 100.0  # Puedes ajustar esta velocidad
			velocity = tangent * speed
			move_and_slide()
		
		shoot_timer += delta
		if shoot_timer >= shoot_interval:
			shoot_timer = 0.0
			shoot_radial_pattern()

func take_damage():
	if esta_muriendo:
		return
			
	health -= 1
	%Slime.play_hurt()
	if health == 0:
		esta_muriendo = true
		%Slime.play_dead()
		
func _on_slime_animation_finished():
	if esta_muriendo:
		queue_free()
		death.emit()
		
func shoot_radial_pattern():
	var num_bullets = 4
	var pattern_angle = randf() * TAU # Ángulo inicial aleatorio para variación
	
	for i in range(num_bullets):
		var angle = pattern_angle + (TAU / num_bullets) * i
		var dir = Vector2(cos(angle), sin(angle))
		
		var bullet = enemy_bullet_scene.instantiate()
		bullet.global_position = global_position
		bullet.direction = dir
		bullet.speed = 300  # Velocidad aleatoria para variedad
		bullet.is_enemy_bullet = true
		bullet.shooter = self
		get_tree().current_scene.add_child(bullet)
