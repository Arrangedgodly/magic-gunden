extends Resource
class_name TutorialSave

@export var has_played:bool = false
@export var show_tutorial:bool = true

func user_has_played():
	has_played = true
	
func update_show_tutorial(new_pref: bool):
	show_tutorial = new_pref
