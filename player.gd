class_name Player
extends CharacterBody2D

signal health_depleted
signal request_bullet_hell
signal request_bullet_hell_end

var health = 100.0

enum PlayerState { NORMAL, BULLET_HELL }
var current_state = PlayerState.NORMAL

var bullet_hell_trigger = 90


func _physics_process(delta):
	var direction = Input.get_vector("move_left","move_right","move_up","move_down")
	velocity = direction * 700
	move_and_slide()
	look_at_mouse()
	if Input.is_action_just_pressed("shoot") and current_state == PlayerState.NORMAL:
		get_node("Gun").shoot()
	if velocity.length() > 0.0:
		get_node("HappyBoo").play_walk_animation()
	else:
		get_node("HappyBoo").play_idle_animation()
		
	const DAMAGE_RATE = 5.0
	var overlapping_mobs = %HurtBox.get_overlapping_bodies()
	if overlapping_mobs.size() > 0:
		health -= DAMAGE_RATE * overlapping_mobs.size() * delta
		updateBar()
		if health <= 0.0:
			health_depleted.emit()
	
		
func _on_timer_timeout():
	if current_state == PlayerState.BULLET_HELL:
		health += 5
		updateBar()
		
func updateBar():
	%ProgressBar.value = health
	
func _process(delta):
	if health <= bullet_hell_trigger and current_state != PlayerState.BULLET_HELL:
		request_bullet_hell.emit()
		health = 10
		current_state = PlayerState.BULLET_HELL
	elif health > bullet_hell_trigger and current_state != PlayerState.NORMAL:
		request_bullet_hell_end.emit()
		current_state = PlayerState.NORMAL

func look_at_mouse():
	var mouse_pos = get_global_mouse_position()
	get_node("Gun/WeaponPivot").look_at(mouse_pos)
