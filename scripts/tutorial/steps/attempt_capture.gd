extends TutorialStep

var has_started_trail: bool = false
var step_finished: bool = false

func _init(tutorial_ref) -> void:
	super(tutorial_ref)
	step_number = 7
	should_pause = true
	can_auto_advance = true

func _execute_step() -> void:
	show_instruction("CAPTURE PRACTICE", "attempt_capture_practice")
	
	has_started_trail = false
	step_finished = false
	
	await pause_and_wait()

func check_auto_advance() -> bool:
	if step_finished:
		return false
	
	var current_trail_size = trail_manager.get_trail_size()
	
	if current_trail_size > 0:
		has_started_trail = true
	
	if has_started_trail and current_trail_size == 0:
		step_finished = true
		tutorial.disable_auto_advance = true
		
		if tutorial and tutorial.get_tree():
			var timer = tutorial.get_tree().create_timer(1.5)
			timer.timeout.connect(func(): advance_to_next())

	return false
