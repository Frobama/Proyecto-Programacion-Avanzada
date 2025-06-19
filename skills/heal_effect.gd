extends Node2D

@onready var sound = $SFX
@onready var animation = $AnimatedSprite2D

func _ready():
	sound.play()
	animation.play("heal")

func _on_animated_sprite_2d_animation_finished() -> void:
	queue_free()
