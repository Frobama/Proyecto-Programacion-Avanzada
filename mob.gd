class_name Mob
extends CharacterBody2D

signal death
var health = 3

const enemy_bullet_scene = preload("res://bullet.tscn")
var shoot_timer := 0.0
var shoot_interval := 0.5

var player: CharacterBody2D = null
	
var bullet_hell_mode = false

var rotation_speed = 1.0 # Velocidad de rotación angular (radianes/segundo)
var orbit_radius = 100.0 # Distancia del mob al jugador
var orbit_angle = 0.0 # Ángulo actual del mob alrededor del jugador

var impulso_actual := Vector2.ZERO
var decaimiento_impulso := 10.0

var esta_muriendo = false
var aturdido = false

func _ready():
	%Slime.play_walk()
	%Slime/Anchor/SlimeBody.animation_finished.connect(_on_slime_animation_finished)
	
func _physics_process(delta):
	if player == null:
		return
		
	if aturdido:
		velocity = impulso_actual
		impulso_actual = impulso_actual.move_toward(Vector2.ZERO, decaimiento_impulso * delta)
		if impulso_actual.length() < 1.0:
			aturdido = false
		move_and_slide()
		return
		
	var dir_velocity := Vector2.ZERO
	
	if not bullet_hell_mode and not esta_muriendo:
		dir_velocity = global_position.direction_to(player.global_position) * 300
		
	elif not bullet_hell_mode and esta_muriendo:
		dir_velocity = global_position.direction_to(player.global_position) * 100
		
	else:
		# Calcular el vector desde el jugador al mob
		var to_mob = global_position - player.global_position

		# Asegurar que tiene la distancia deseada
		var current_distance = to_mob.length()
		var desired_distance = 600.0  # Puedes ajustar este valor

		if abs(current_distance - desired_distance) > 10:
			# Moverse radialmente hacia la distancia deseada de forma suave
			var radial_direction = to_mob.normalized()
			dir_velocity = radial_direction * ((desired_distance - current_distance) * 2.0)
		else:
			# Calcular vector tangente (rotación 90°)
			var tangent = Vector2(-to_mob.y, to_mob.x).normalized()
			dir_velocity = tangent * 100.0
			
		
		shoot_timer += delta
		if shoot_timer >= shoot_interval:
			shoot_timer = 0.0
			shoot_radial_pattern()
	
	impulso_actual = impulso_actual.move_toward(Vector2.ZERO, decaimiento_impulso * delta)
	velocity = dir_velocity + impulso_actual
	move_and_slide()
	
func take_damage(damage):
	if esta_muriendo:
		return

	health -= damage
	%Slime.play_hurt()
	if health <= 0:
		esta_muriendo = true
		%Slime.play_dead()
		
func _on_slime_animation_finished():
	if esta_muriendo:
		
		var popup_scene = preload("res://pop_up_label/pop_up_label.tscn")
		var popup = popup_scene.instantiate()
		popup.global_position = global_position
		popup.start("+$1")
		get_tree().current_scene.add_child(popup)

		death.emit()
		$"../Player".add_money(1)
		queue_free()

	
		
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

func empujar(impulso: Vector2) -> void:
	impulso_actual += impulso
	aturdido = true
	await get_tree().create_timer(0.1).timeout # Duración del empuje
	aturdido = false
