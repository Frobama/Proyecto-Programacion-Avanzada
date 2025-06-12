extends Area2D

@export var empuje = 320
@export var duracion = 1
@onready var hitbox = $Hitbox
@onready var sound = $SFX

func _ready():
	$Hitbox/CollisionShape2D.disabled = false
	$AnimatedSprite2D.play("default")
	sound.play()
	get_viewport().get_camera_2d().shake()
	await get_tree().create_timer(0.05).timeout
	empujar()
	await get_tree().create_timer(duracion).timeout
	queue_free()

	
func empujar():
	var bodies = hitbox.get_overlapping_bodies()
	for body in bodies:
		print("Cuerpo detectado:", body.name)
		if body.has_method("empujar"):
			print("mob empujado")
			var direccion = (body.global_position - global_position).normalized()
			body.empujar(empuje * direccion)
