extends Area2D

@onready var timer = $Timer
@onready var already_hit = []
@onready var animation = $AnimatedSprite2D
@onready var hitbox = $Hitbox
var moving = true
var speed = 100
var direction = Vector2.ZERO

func _ready():
	animation.play("travel")
	hitbox.monitoring = true
	hitbox.monitorable = true
	$Hitbox/CollisionShape2D.disabled = false




func _physics_process(delta):
	position += direction * speed * delta
	if speed > 0.1:
		speed -= 0.1

func _on_body_entered(body):
	if body.name == "Player":
		return
	else:
		explotar()
	
	
func explotar():
	speed = 0
	direction = Vector2.ZERO
	
	$Hitbox/CollisionShape2D.shape.radius = 200
	hitbox.monitoring = true
	
	await get_tree().process_frame
	await get_tree().process_frame
	timer.start()
	print("radio actual: ", $Hitbox/CollisionShape2D.shape.radius)

	
	
		
		
func _on_animated_sprite_2d_animation_finished() -> void:
	if animation.animation == "hit":
		$Hitbox/CollisionShape2D.shape.radius = 28
		queue_free()
		


func _on_timer_timeout() -> void:
	var bodies = hitbox.get_overlapping_bodies()
	for body in bodies:	
		if body.has_method("take_damage"):
			print("mob entro a hitbox")
			body.take_damage(3)
		
	hitbox.monitoring = false
	animation.play("hit")
