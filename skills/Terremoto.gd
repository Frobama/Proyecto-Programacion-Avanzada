extends Skill
class_name Terremoto

func _init(target):
	cooldown = 8.0
	animation_name = "Terremoto"
	
	texture = preload("res://skill_sprites/terremoto.png")
	
	super._init(target)
	
func cast_skill(target):
	super.cast_skill(target)
	var terremoto_scene = preload("res://skills/Terremoto.tscn")
	var terremoto = terremoto_scene.instantiate()
	terremoto.global_position = target.global_position
	
	target.get_tree().current_scene.add_child(terremoto)
