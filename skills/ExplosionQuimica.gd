extends Skill
class_name ExplosionQuimica

func _init(target):
	cooldown = 5.0
	animation_name = "Quimica"
	
	texture = preload("res://skill_sprites/expquim.png")
	
	super._init(target)
	
func cast_skill(target):
	super.cast_skill(target)
	var explosion_scene = preload("res://skills/ExplosionQuimica.tscn")
	var explosion = explosion_scene.instantiate()
	explosion.global_position = target.global_position
	
	var angle = target.get_node("Gun/WeaponPivot/Pistol/ShootingPart").global_rotation
	explosion.direction = Vector2.RIGHT.rotated(angle)
	
	target.get_tree().current_scene.add_child(explosion)
