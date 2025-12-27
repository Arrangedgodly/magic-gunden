extends TutorialStep

func _init(tutorial_ref) -> void:
	super(tutorial_ref)
	step_number = 1
	should_pause = true

func _execute_step() -> void:
	tutorial.get_tree().paused = true
	show_instruction("Welcome to Magic Garden!", "welcome")
	await pause_and_wait()
	advance_to_next()
