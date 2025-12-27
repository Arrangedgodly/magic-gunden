extends TutorialStep

func _init(tutorial_ref) -> void:
	super(tutorial_ref)
	step_number = 4
	should_pause = true

func _execute_step() -> void:
	tutorial._show_tutorial()
	show_instruction("CAPTURE ZONES", "capture_zones")
	AudioManager.play_sound(tutorial.capture_sfx)
	await pause_and_wait()
	advance_to_next()
