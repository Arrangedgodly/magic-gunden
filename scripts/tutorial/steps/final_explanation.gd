extends TutorialStep

func _init(tutorial_ref) -> void:
	super(tutorial_ref)
	step_number = 14
	should_pause = true

func _execute_step() -> void:
	show_instruction("TUTORIAL COMPLETE!", "final")
	AchievementManager.progress_achievement("complete_tutorial", 1)
	await pause_and_wait()
	advance_to_next()
