extends TutorialStep

func _init(tutorial_ref) -> void:
	super(tutorial_ref)

func _execute_step() -> void:
	if powerup_manager:
		var stomp_scene = preload("res://scenes/powerups/stomp.tscn")
		powerup_manager.force_spawn_powerup(stomp_scene)
	
	if tutorial and tutorial.get_tree():
		await tutorial.get_tree().create_timer(0.3).timeout
		advance_to_next()
