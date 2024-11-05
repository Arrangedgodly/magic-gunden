extends Resource
class_name Ammo

@export var ammo_count:int
@export var clip_count:int

func increase_ammo():
	ammo_count += 1
	clip_count = ammo_count / 6
	
func decrease_ammo():
	ammo_count -= 1
	clip_count = ammo_count / 6
