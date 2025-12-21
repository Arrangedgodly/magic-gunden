extends TutorialStep
class_name SpawnGemsForCaptureLessonStep

func _init(tutorial_ref: Tutorial) -> void:
	super(tutorial_ref)

func _execute_step() -> void:
	if capture_manager:
		capture_manager.clear_capture_points()
	
	await tutorial.get_tree().create_timer(0.3).timeout
	
	if capture_manager:
		capture_manager.tutorial_pattern = true
		var spawn_point = Vector2i(96, 96)
		capture_manager.spawn_capture_points(spawn_point)
	
	await tutorial.get_tree().create_timer(0.5).timeout
	
	if trail_manager:
		trail_manager.create_multiple_trail_segments(5)
	
	await tutorial.get_tree().create_timer(0.5).timeout
	advance_to_next()
