extends Control

var tutorial_save: TutorialSave

@onready var tutorial_panel: Panel = $TutorialPanel
@onready var instruction_label: Label = $TutorialPanel/MarginContainer/VBoxContainer/InstructionLabel
@onready var hint_label: Label = $TutorialPanel/MarginContainer/VBoxContainer/HintLabel
@onready var progress_label: Label = $TutorialPanel/MarginContainer/VBoxContainer/ProgressLabel
@onready var skip_button: Button = $TutorialPanel/MarginContainer/VBoxContainer/SkipButton

var game_manager: Node2D
var player: CharacterBody2D
var trail_manager: TrailManager

enum TutorialStep {
	WELCOME,
	MOVEMENT,
	PICKUP_GEM,
	CAPTURE_GEM,
	DETACH_TRAIL,
	AIM,
	SHOOT,
	POWERUP_EXPLANATION,
	COMPLETE
}

var current_step: TutorialStep = TutorialStep.WELCOME
var tutorial_active: bool = false
var waiting_for_continue: bool = false
var game_was_paused: bool = false

var has_moved: bool = false
var has_picked_up_gem: bool = false
var gems_collected: int = 0
var has_captured_gem: bool = false
var has_detached: bool = false
var has_aimed: bool = false
var has_shot: bool = false

signal tutorial_finished

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	game_manager = get_node_or_null("/root/MagicGarden/GameManager")
	player = get_node_or_null("/root/MagicGarden/Player")
	trail_manager = get_node_or_null("/root/MagicGarden/TrailManager")
	
	tutorial_save = load("user://tutorial.tres") as TutorialSave
	if tutorial_save == null:
		tutorial_save = TutorialSave.new()
	
	if tutorial_save.show_tutorial:
		tutorial_active = true
		show()
		start_tutorial()
	else:
		tutorial_finished.emit()
		queue_free()
		return
	
	if skip_button:
		skip_button.pressed.connect(_on_skip_pressed)

func start_tutorial() -> void:
	current_step = TutorialStep.WELCOME
	show_step()

func show_step() -> void:
	match current_step:
		TutorialStep.WELCOME:
			show_welcome()
		TutorialStep.MOVEMENT:
			show_movement()
		TutorialStep.PICKUP_GEM:
			show_pickup_gem()
		TutorialStep.CAPTURE_GEM:
			show_capture_gem()
		TutorialStep.DETACH_TRAIL:
			show_detach_trail()
		TutorialStep.AIM:
			show_aim()
		TutorialStep.SHOOT:
			show_shoot()
		TutorialStep.POWERUP_EXPLANATION:
			show_powerup_explanation()
		TutorialStep.COMPLETE:
			complete_tutorial()

func show_welcome() -> void:
	instruction_label.text = "Welcome to Magic Garden!"
	hint_label.text = "Collect gems, capture them on points, and survive!"
	progress_label.text = "Step 1/8"
	
	await get_tree().create_timer(3.0).timeout
	if tutorial_active:
		next_step()

func show_movement() -> void:
	instruction_label.text = "MOVEMENT"
	hint_label.text = "Press WASD or Arrow Keys to start moving!"
	progress_label.text = "Step 2/8"

func show_pickup_gem() -> void:
	instruction_label.text = "COLLECT GEMS"
	hint_label.text = "Walk over the blue gem to pick it up. This creates a trail!"
	progress_label.text = "Step 3/8"

func show_capture_gem() -> void:
	instruction_label.text = "CAPTURE GEMS"
	hint_label.text = "Move your trail gems over the glowing capture points!"
	progress_label.text = "Step 4/8"

func show_detach_trail() -> void:
	instruction_label.text = "DETACH TRAIL"
	hint_label.text = "Press E to detach your trail. Gems on points = ammo! Gems off points = enemies!"
	progress_label.text = "Step 5/8"

func show_aim() -> void:
	instruction_label.text = "AIMING"
	hint_label.text = "Use the Arrow Keys to aim your shot."
	progress_label.text = "Step 6/8"

func show_shoot() -> void:
	instruction_label.text = "SHOOTING"
	hint_label.text = "Press SPACE to shoot! Hit the enemies to defeat them."
	progress_label.text = "Step 7/8"

func show_powerup_explanation() -> void:
	instruction_label.text = "POWER-UPS"
	hint_label.text = "Capture 6+ gems at once to spawn a power-up with special abilities!"
	progress_label.text = "Step 8/8"
	
	await get_tree().create_timer(5.0).timeout
	if tutorial_active:
		next_step()

func complete_tutorial() -> void:
	instruction_label.text = "TUTORIAL COMPLETE!"
	hint_label.text = "You're ready! Good luck surviving in the Magic Garden!"
	progress_label.text = "Complete!"
	
	await get_tree().create_timer(3.0).timeout
	finish_tutorial()

func _process(_delta: float) -> void:
	if not tutorial_active:
		return
	
	match current_step:
		TutorialStep.MOVEMENT:
			check_movement()
		TutorialStep.PICKUP_GEM:
			check_gem_pickup()
		TutorialStep.CAPTURE_GEM:
			check_gem_capture()
		TutorialStep.DETACH_TRAIL:
			check_trail_detach()
		TutorialStep.AIM:
			check_aiming()
		TutorialStep.SHOOT:
			check_shooting()

func check_movement() -> void:
	if game_manager and game_manager.game_started and not has_moved:
		has_moved = true
		if tutorial_active:
			next_step()

func check_gem_pickup() -> void:
	if trail_manager and trail_manager.get_trail_size() > gems_collected:
		gems_collected = trail_manager.get_trail_size()
		if not has_picked_up_gem:
			has_picked_up_gem = true
			if tutorial_active:
				next_step()

func check_gem_capture() -> void:
	if trail_manager and trail_manager.get_trail_size() >= 2:
		var on_capture = check_gems_on_capture_points()
		if on_capture and not has_captured_gem:
			has_captured_gem = true
			if tutorial_active:
				next_step()

func check_gems_on_capture_points() -> bool:
	var capture_points = get_tree().get_nodes_in_group("capture")
	for point in capture_points:
		if point.has_method("check_detected_body"):
			var detected = point.check_detected_body()
			if detected != null:
				return true
	return false

func check_trail_detach() -> void:
	if Input.is_action_just_pressed("detach") and not has_detached:
		has_detached = true
		if tutorial_active:
			next_step()

func check_aiming() -> void:
	var aiming = Input.is_action_pressed("aim-up") or Input.is_action_pressed("aim-down") or \
				 Input.is_action_pressed("aim-left") or Input.is_action_pressed("aim-right")
	
	if aiming and not has_aimed:
		has_aimed = true
		if tutorial_active:
			next_step()

func check_shooting() -> void:
	if Input.is_action_just_pressed("attack") and not has_shot:
		has_shot = true
		if tutorial_active:
			next_step()

func next_step() -> void:
	current_step = TutorialStep.values()[current_step + 1] as TutorialStep
	show_step()

func finish_tutorial() -> void:
	tutorial_active = false
	
	tutorial_save.show_tutorial = false
	ResourceSaver.save(tutorial_save, "user://tutorial.tres")
	
	tutorial_finished.emit()
	queue_free()

func _on_skip_pressed() -> void:
	finish_tutorial()

func _input(event: InputEvent) -> void:
	if tutorial_active and event.is_action_pressed("ui_cancel"):
		_on_skip_pressed()
