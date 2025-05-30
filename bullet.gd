extends Area2D

@export var direction := Vector2.RIGHT
@export var speed := 1000.0
@export var range := 1200.0
@export var is_enemy_bullet := false

var travelled_distance := 0.0

var shooter = null #la entidad que dispara la bala

func _ready():
	add_to_group("balas")
	
func _physics_process(delta):
	position += direction.normalized() * speed * delta
	travelled_distance += speed * delta
	rotation = direction.angle()
	if travelled_distance > range:
		queue_free()

func _on_body_entered(body):
	if body == shooter:
		return #Se evita que la bala choque con la propia hitbox del que dispara
	if is_enemy_bullet and body.name == "Player":
		body.health -= 5
		body.updateBar()
	elif not is_enemy_bullet and body.name != "Player":
		if body.has_method("take_damage"):
			body.take_damage(1)
	
	queue_free()
