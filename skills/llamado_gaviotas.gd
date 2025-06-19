extends Skill
class_name Gaviotas

@export var gaviota_escena = preload("res://skills/Gaviota.tscn")
@export var cantidad_entidades: int = 9
@export var radio: float = 200.0


func _init(target):
	cooldown = 10.0
	animation_name = "Gaviota"
	
	texture = preload("res://skill_sprites/gaviota_button.png")
	
	super._init(target)
	
func cast_skill(target):
	super.cast_skill(target)
	var jugador = target.global_position
	
	
	for i in range(cantidad_entidades):
		
		var gaviota = gaviota_escena.instantiate()
		gaviota.iniciar(target, i, cantidad_entidades, radio)
		target.get_tree().current_scene.add_child(gaviota)
	
	var sfx = AudioStreamPlayer.new()
	sfx.stream = preload("res://sounds/seagull.wav")
	target.get_tree().current_scene.add_child(sfx)
	for i in range(4):
		sfx.play()
		await target.get_tree().create_timer(0.5).timeout
		
