extends TutorialStep

func _init(tutorial_ref) -> void:
	super(tutorial_ref)
	step_number = 13
	should_pause = true
	can_auto_advance = true

func _execute_step() -> void:
	show_instruction("TEST STOMP", "test_powerup")
	
	if powerup_manager and powerup_manager.active_stomp:
		var stomp_timer = powerup_manager.active_stomp.get_timer()
		if stomp_timer:
			stomp_timer.paused = true
			
	tutorial.test_enemies_killed = 0
	spawn_test_enemies(5)
	await pause_and_wait()

func spawn_test_enemies(count: int) -> void:
	if not enemy_manager:
		return

	for i in range(count):
		if tutorial and tutorial.get_tree():
			await tutorial.get_tree().create_timer(0.3).timeout
			enemy_manager.spawn_enemy()

func check_auto_advance() -> bool:
	return tutorial.test_enemies_killed >= 1

func exit() -> void:
	super.exit()

	if powerup_manager and powerup_manager.active_stomp:
		var stomp_timer = powerup_manager.active_stomp.get_timer()
		if stomp_timer:
			stomp_timer.paused = false
