class_name Player
extends CharacterBody2D

signal health_depleted
signal request_bullet_hell
signal request_bullet_hell_end
signal money_change

var health = 100.0
var max_health = 100
var contaminacion = 0

enum PlayerState { NORMAL, BULLET_HELL }
var current_state = PlayerState.NORMAL

var bullet_hell_trigger = 50

@export var money = 0

func _physics_process(delta):
	var direction = Input.get_vector("move_left","move_right","move_up","move_down")
	velocity = direction * 700
	move_and_slide()
	look_at_mouse()
	if Input.is_action_just_pressed("shoot") and current_state == PlayerState.NORMAL:
		get_node("Gun").shoot()
	if velocity.length() > 0.0:
		%Ucenin.play("ucenin_walk")
		
	#else:
		#get_node("Ucenin").play_idle_animation()
		
	const DAMAGE_RATE = 5.0
	var overlapping_mobs = %HurtBox.get_overlapping_bodies()
	if overlapping_mobs.size() > 0:
		health -= DAMAGE_RATE * overlapping_mobs.size() * delta
		contaminacion += DAMAGE_RATE * overlapping_mobs.size() * delta * 1.5
		updateBar()
	if health <= 0.0:
		health_depleted.emit()


func _on_timer_timeout():
	if current_state == PlayerState.BULLET_HELL:
		contaminacion -= 5
		health += 1
		if health > max_health:
			health = max_health
		updateBar()
		
	else:
		health += 1
		if health > max_health:
			health = max_health
		updateBar()
func updateBar():
	%ProgressBar.value = health
	%TextureProgressBar.value = contaminacion
	money_change.emit()
func _process(delta):
	if contaminacion >= 90 and current_state != PlayerState.BULLET_HELL:
		request_bullet_hell.emit()
		current_state = PlayerState.BULLET_HELL
	elif contaminacion < 10 and current_state != PlayerState.NORMAL:
		request_bullet_hell_end.emit()
		current_state = PlayerState.NORMAL
		contaminacion = 0

func look_at_mouse():
	var mouse_pos = get_global_mouse_position()
	get_node("Gun/WeaponPivot").look_at(mouse_pos)

func add_money(cantidad):
	money += cantidad
	emit_signal("money_change", money)

func heal(amount):
	health += amount
	health = min(health, max_health)
	updateBar()

func mostrar_mensaje_ataque(tipo: String):
	var label = $UI/AttackNotification
	
	label.text = "¡ALERTA!"
	label.visible = true
	var sound = preload("res://sounds/alert.wav")
	var sfx = AudioStreamPlayer.new()
	sfx.stream = sound
	sfx.volume_db = -8
	get_tree().current_scene.add_child(sfx)
	sfx.play()
	
	await get_tree().create_timer(1.0).timeout
	sfx.queue_free()
	
	label.text = "¡Ataque recibido: %s!"%tipo
	label.visible = true
	label.modulate.a = 1.0
	var tween = create_tween()
	tween.tween_property(label,"modulate:a", 0.0, 5.0).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
	await tween.finished
	label.visible = false
