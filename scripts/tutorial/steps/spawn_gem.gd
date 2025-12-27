extends TutorialStep

func _init(tutorial_ref) -> void:
	super(tutorial_ref)

func _execute_step() -> void:
	tutorial.cleanup_tutorial_spawns()
	
	if pickup_manager:
		pickup_manager.force_spawn_gem()
	
	advance_to_next()
