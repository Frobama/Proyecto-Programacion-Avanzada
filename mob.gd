extends CharacterBody2D

var health = 3

var player: CharacterBody2D = null
	
func _ready():
	%Slime.play_walk()
	
func _physics_process(delta):
<<<<<<< Updated upstream
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * 300.0
	move_and_slide()
=======
	
	if player == null:
		return
		
	if not bullet_hell_mode:
		var direction = global_position.direction_to(player.global_position)
		velocity = direction * 300.0
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

>>>>>>> Stashed changes

func take_damage():
	health -= 1
	%Slime.play_hurt()
	if health == 0:
		queue_free()
