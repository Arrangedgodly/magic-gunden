extends RefCounted
class_name TutorialStep

var tutorial: Tutorial
var game_manager: Node2D
var player: CharacterBody2D
var trail_manager: TrailManager
var enemy_manager: EnemyManager
var capture_manager: CapturePointManager
var pickup_manager: PickupManager
var powerup_manager: PowerupManager
var ammo_manager: AmmoManager

var instruction_label: Label
var hint_label: RichTextLabel
var progress_label: Label

var step_number: int = 0
var total_steps: int = 14
var should_pause: bool = false
var can_auto_advance: bool = false
var requires_wait_after_continue: bool = false

var _connected_signals: Array[Dictionary] = []

func _init(tutorial_ref: Tutorial) -> void:
	tutorial = tutorial_ref
	_setup_references()

func _setup_references() -> void:
	game_manager = tutorial.game_manager
	player = tutorial.player
	trail_manager = tutorial.trail_manager
	enemy_manager = tutorial.enemy_manager
	capture_manager = tutorial.capture_manager
	pickup_manager = tutorial.pickup_manager
	powerup_manager = tutorial.powerup_manager
	ammo_manager = tutorial.ammo_manager

	instruction_label = tutorial.instruction_label
	hint_label = tutorial.hint_label
	progress_label = tutorial.progress_label

func enter() -> void:
	tutorial.disable_auto_advance = true
	_setup_ui()
	_connect_signals()
	await _execute_step()

func _execute_step() -> void:
	pass

func _setup_ui() -> void:
	if step_number > 0:
		progress_label.text = "Step %d/%d" % [step_number, total_steps]

func _connect_signals() -> void:
	pass

func exit() -> void:
	_disconnect_signals()
	_cleanup()

func _cleanup() -> void:
	pass

func check_auto_advance() -> bool:
	return false

func connect_signal(object: Object, signal_name: String, callable: Callable) -> void:
	if object and object.has_signal(signal_name):
		object.connect(signal_name, callable)
		_connected_signals.append({
			"object": object,
			"signal_name": signal_name,
			"callable": callable
		})

func _disconnect_signals() -> void:
	for sig_data in _connected_signals:
		var obj = sig_data.object
		if obj and obj.has_signal(sig_data.signal_name):
			if obj.is_connected(sig_data.signal_name, sig_data.callable):
				obj.disconnect(sig_data.signal_name, sig_data.callable)
	_connected_signals.clear()

func pause_and_wait() -> void:
	tutorial.waiting_for_continue = true
	tutorial._show_tutorial()
	hint_label.prompt_continue()
	
	if requires_wait_after_continue:
		tutorial.should_wait = true

	while tutorial.waiting_for_continue:
		await tutorial.get_tree().process_frame
	
	if tutorial.should_wait:
		await tutorial.get_tree().create_timer(2.0).timeout
		tutorial.should_wait = false
	
	if can_auto_advance:
		tutorial.disable_auto_advance = false

func advance_to_next() -> void:
	tutorial.next_step()

func show_instruction(title: String, hint_method: String) -> void:
	instruction_label.text = title
	hint_label.call(hint_method)
