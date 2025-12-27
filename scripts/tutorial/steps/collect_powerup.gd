extends TutorialStep

func _init(tutorial_ref) -> void:
	super(tutorial_ref)
	step_number = 12
	should_pause = true
	can_auto_advance = true

func _execute_step() -> void:
	show_instruction("POWERUPS", "stomp_powerup")
	await pause_and_wait()

func check_auto_advance() -> bool:
	return powerup_manager and powerup_manager.is_stomp_active()
