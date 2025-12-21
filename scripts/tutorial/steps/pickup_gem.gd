extends TutorialStep
class_name PickupGemStep

func _init(tutorial_ref: Tutorial) -> void:
	super(tutorial_ref)
	step_number = 3
	should_pause = true
	can_auto_advance = true
	requires_wait_after_continue = true

func _execute_step() -> void:
	tutorial._show_tutorial()
	show_instruction("COLLECT GEMS", "gem_pickup")
	AudioManager.play_sound(tutorial.pickup_sfx)
	await pause_and_wait()

func check_auto_advance() -> bool:
	return trail_manager.get_trail_size() > 0
