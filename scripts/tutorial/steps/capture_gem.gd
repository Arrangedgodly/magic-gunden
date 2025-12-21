extends TutorialStep
class_name CaptureGemStep

var _signal_received: bool = false

func _init(tutorial_ref: Tutorial) -> void:
	super(tutorial_ref)
	step_number = 5
	should_pause = true
	can_auto_advance = false

func _execute_step() -> void:
	show_instruction("GET AMMO", "capture_gems")
	await pause_and_wait()

func _connect_signals() -> void:
	if trail_manager:
		connect_signal(trail_manager, "trail_item_converted_to_ammo", _on_trail_converted)

func _on_trail_converted() -> void:
	if _signal_received:
		return
		
	_signal_received = true
	
	if trail_manager:
		trail_manager.tutorial_capture = true
	
	await tutorial.get_tree().create_timer(0.5).timeout
	
	if capture_manager:
		capture_manager.clear_capture_points()
		var spawn_point = capture_manager.find_capture_spawn_point()
		capture_manager.spawn_capture_points(spawn_point)
	
	advance_to_next()

func check_auto_advance() -> bool:
	return _signal_received
