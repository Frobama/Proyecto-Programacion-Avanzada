extends HBoxContainer

var slots : Array

func _ready():
	slots = get_children()
	for i in get_child_count():
		slots[i].change_key = str(i+1)
		
	
	slots[0].skill = ExplosionQuimica.new(slots[0])
