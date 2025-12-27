extends TutorialStep

func _init(tutorial_ref) -> void:
	super(tutorial_ref)
	step_number = 6
	should_pause = true

func _execute_step() -> void:
	show_instruction("ZONES MOVE", "zone_movement")
	await pause_and_wait()
	
	if capture_manager:
		for i in range(3):
			capture_manager.flash_capture_points()
			if tutorial and tutorial.get_tree():
				await tutorial.get_tree().create_timer(0.5).timeout
		
		if tutorial and tutorial.get_tree():
			await tutorial.get_tree().create_timer(1.0).timeout

		capture_manager.clear_capture_points()
		var spawn_point = capture_manager.find_capture_spawn_point()
		capture_manager.spawn_capture_points(spawn_point)
	
	advance_to_next()
