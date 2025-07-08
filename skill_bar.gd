extends HBoxContainer

@onready var slots : Array = []

func _ready():
	slots = get_children()
	
	
	slots[0].skill = ExplosionQuimica.new(slots[0])
	slots[0].disabled = true
	slots[1].skill = Gaviotas.new(slots[1])
	slots[1].disabled = true
	slots[2].skill = Terremoto.new(slots[2])
	slots[2].disabled = true
	slots[3].skill = Botiquin.new(slots[3])
	slots[3].disabled = true
	
func get_slots():
	return slots
