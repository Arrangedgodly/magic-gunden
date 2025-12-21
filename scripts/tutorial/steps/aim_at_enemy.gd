extends TutorialStep
class_name AimAtEnemyStep

var initial_aim: Vector2
var input_delay_active: bool = true
var success_detected: bool = false

func _init(tutorial_ref: Tutorial) -> void:
	super(tutorial_ref)
	step_number = 10
	should_pause = true
	can_auto_advance = true

func _execute_step() -> void:
	show_instruction("AIMING", "aiming")

	if player:
		initial_aim = player.aim_direction
		
	await pause_and_wait()

	input_delay_active = true
	await tutorial.get_tree().create_timer(0.5).timeout
	input_delay_active = false

func check_auto_advance() -> bool:
	if success_detected or input_delay_active:
		return false

	if player:
		if player.aim_direction.distance_to(initial_aim) > 0.1:
			_trigger_delayed_success()
			
	return false

func _trigger_delayed_success() -> void:
	success_detected = true
	tutorial.has_aimed = true

	await tutorial.get_tree().create_timer(2.0).timeout

	advance_to_next()
