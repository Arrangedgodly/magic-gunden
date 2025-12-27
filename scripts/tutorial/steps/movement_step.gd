extends TutorialStep

func _init(tutorial_ref) -> void:
	super(tutorial_ref)
	step_number = 2
	should_pause = true
	can_auto_advance = true
	requires_wait_after_continue = true

func _execute_step() -> void:
	show_instruction("MOVEMENT", "movement")
	await pause_and_wait()

func check_auto_advance() -> bool:
	return tutorial.has_moved
