extends TutorialStep

func _init(tutorial_ref) -> void:
	super(tutorial_ref)
	step_number = 9
	should_pause = true

func _execute_step() -> void:
	show_instruction("ENEMY BEHAVIOR", "enemy_movement")
	await pause_and_wait()
	
	if enemy_manager:
		enemy_manager.move_all_enemies()
	
	if tutorial and tutorial.get_tree():
		await tutorial.get_tree().create_timer(1.5).timeout
		advance_to_next()
