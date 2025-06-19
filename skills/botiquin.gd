extends Skill
class_name Botiquin

func _init(target):
	cooldown = 10.0
	animation_name = "Botiquin"
	
	texture = preload("res://skill_sprites/botiquin.png")
	
	super._init(target)
	
func cast_skill(target):
	super.cast_skill(target)
	
	if target.has_method("heal"):
		target.heal(40)
		
	var heal_scene = preload("res://skills/HealEffect.tscn")
	var effect = heal_scene.instantiate()
	effect.global_position = target.global_position
	target.get_tree().current_scene.add_child(effect)
