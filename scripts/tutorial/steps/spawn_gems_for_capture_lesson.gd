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
		var spawn_point = _choose_random_spawn_point()
		capture_manager.spawn_capture_points(spawn_point)
	
	await tutorial.get_tree().create_timer(0.5).timeout
	
	if trail_manager:
		trail_manager.create_multiple_trail_segments(5)
	
	await tutorial.get_tree().create_timer(0.5).timeout
	advance_to_next()

func _choose_random_spawn_point() -> Vector2i:
	var x = randi_range(1, 6) * 32
	var y = randi_range(1, 6) * 32
	return Vector2i(x, y)
