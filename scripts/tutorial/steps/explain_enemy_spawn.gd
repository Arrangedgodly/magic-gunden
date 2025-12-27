extends TutorialStep

func _init(tutorial_ref) -> void:
	super(tutorial_ref)
	step_number = 8
	should_pause = true

func _execute_step() -> void:
	if capture_manager:
		capture_manager.tutorial_pattern = false
	
	show_instruction("ENEMY SPAWNING", "explain_enemy_spawn")
	await pause_and_wait()
	advance_to_next()
