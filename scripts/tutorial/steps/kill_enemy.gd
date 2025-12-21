extends TutorialStep
class_name KillEnemyStep

func _init(tutorial_ref: Tutorial) -> void:
	super(tutorial_ref)
	step_number = 11
	should_pause = true
	can_auto_advance = true

func _execute_step() -> void:
	tutorial.tutorial_protection_active = true
	tutorial.test_enemies_killed = 0
	show_instruction("ATTACK", "kill_enemy")
	await pause_and_wait()

func check_auto_advance() -> bool:
	return tutorial.test_enemies_killed >= 1

func exit() -> void:
	super.exit()
	tutorial.tutorial_protection_active = false
