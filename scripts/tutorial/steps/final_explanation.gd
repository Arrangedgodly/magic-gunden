extends TutorialStep
class_name FinalExplanationStep

func _init(tutorial_ref: Tutorial) -> void:
	super(tutorial_ref)
	step_number = 14
	should_pause = true

func _execute_step() -> void:
	show_instruction("TUTORIAL COMPLETE!", "final")
	await pause_and_wait()
	advance_to_next()
