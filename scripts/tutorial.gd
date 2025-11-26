extends Control

var tutorial_save: TutorialSave

@onready var tutorial_panel: Panel = $TutorialPanel
@onready var instruction_label: Label = $TutorialPanel/MarginContainer/VBoxContainer/InstructionLabel
@onready var hint_label: Label = $TutorialPanel/MarginContainer/VBoxContainer/HintLabel
@onready var progress_label: Label = $TutorialPanel/MarginContainer/VBoxContainer/ProgressLabel
@onready var skip_button: Button = $TutorialPanel/MarginContainer/VBoxContainer/SkipButton

@onready var game_manager: Node2D = get_node("/root/MagicGarden/GameManager")
@onready var player: CharacterBody2D = get_node("/root/MagicGarden/Player")
@onready var pickup_manager: PickupManager = get_node("/root/MagicGarden/PickupManager")
@onready var trail_manager: TrailManager = get_node("/root/MagicGarden/TrailManager")
@onready var capture_point_manager: CapturePointManager = get_node("/root/MagicGarden/CapturePointManager")
@onready var enemy_manager: EnemyManager = get_node("/root/MagicGarden/EnemyManager")

enum TutorialStep {
	WELCOME,
	MOVEMENT,
	PICKUP_GEM,
	CAPTURE_GEM,
	DETACH_TRAIL,
	AIM,
	SHOOT,
	POWERUP_EXPLANATION,
	STOMP_DEMO,
	COMPLETE
}

var current_step: TutorialStep = TutorialStep.WELCOME
var has_moved: bool = false
var has_picked_up_gem: bool = false
var has_captured_gem: bool = false
var has_detached: bool = false
var has_aimed: bool = false
var has_shot: bool = false
var gems_in_trail: int = 0
var tutorial_active: bool = false

signal tutorial_finished

func _ready() -> void:
	get_tree().paused = true
	process_mode = Node.PROCESS_MODE_ALWAYS
	
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
	
	skip_button.pressed.connect(_on_skip_pressed)
	
	if game_manager:
		game_manager.set_process_input(false)
	if enemy_manager:
		enemy_manager.stop_enemy_systems()
	if capture_point_manager:
		capture_point_manager.stop_capture_systems()

func _process(_delta: float) -> void:
	if not tutorial_active:
		return
	
	match current_step:
		TutorialStep.MOVEMENT:
			check_movement_input()
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
		TutorialStep.STOMP_DEMO:
			show_stomp_demo()
		TutorialStep.COMPLETE:
			complete_tutorial()

func show_welcome() -> void:
	instruction_label.text = "Welcome to Magic Garden!"
	hint_label.text = "Learn the basics to survive against the slimes."
	progress_label.text = "Step 1/9"
	
	await get_tree().create_timer(3.0).timeout
	if tutorial_active:
		next_step()

func show_movement() -> void:
	instruction_label.text = "MOVEMENT"
	hint_label.text = "Use WASD or Arrow Keys to move in four directions."
	progress_label.text = "Step 2/9"
	
	if game_manager:
		game_manager.set_process_input(true)

func check_movement_input() -> void:
	if Input.is_action_pressed("move-up") or Input.is_action_pressed("move-down") or \
	   Input.is_action_pressed("move-left") or Input.is_action_pressed("move-right"):
		if not has_moved:
			has_moved = true
			await get_tree().create_timer(2.0).timeout
			if tutorial_active:
				next_step()

func show_pickup_gem() -> void:
	instruction_label.text = "COLLECT GEMS"
	hint_label.text = "Walk over the blue gem to pick it up. This creates a trail behind you!"
	progress_label.text = "Step 3/9"
	
	if pickup_manager:
		pickup_manager.regen_yoyo = true
	
	if pickup_manager and not pickup_manager.yoyo_collected.is_connected(_on_gem_collected):
		pickup_manager.yoyo_collected.connect(_on_gem_collected)

func _on_gem_collected() -> void:
	if current_step == TutorialStep.PICKUP_GEM and not has_picked_up_gem:
		has_picked_up_gem = true
		await get_tree().create_timer(1.5).timeout
		if tutorial_active:
			next_step()

func check_gem_pickup() -> void:
	pass

func show_capture_gem() -> void:
	instruction_label.text = "CAPTURE GEMS"
	hint_label.text = "Move your trail gems over the glowing capture points! Watch them light up."
	progress_label.text = "Step 4/9"
	
	if capture_point_manager:
		capture_point_manager.initialize_first_spawn()
	
	if pickup_manager:
		pickup_manager.regen_yoyo = true

func check_gem_capture() -> void:
	if trail_manager:
		var on_capture = 0
		for gem in trail_manager.trail:
			if is_gem_on_capture_point(gem):
				on_capture += 1
		
		if on_capture > 0 and not has_captured_gem:
			has_captured_gem = true
			await get_tree().create_timer(2.0).timeout
			if tutorial_active:
				next_step()

func is_gem_on_capture_point(gem: Node2D) -> bool:
	var capture_points = get_tree().get_nodes_in_group("capture")
	for point in capture_points:
		if point.check_detected_body() == gem:
			return true
	return false

func show_detach_trail() -> void:
	instruction_label.text = "CONVERT GEMS"
	hint_label.text = "Press SPACE to detach your trail. Gems on capture points become ammo!\nGems NOT on points become enemies!"
	progress_label.text = "Step 5/9"

func check_trail_detach() -> void:
	if Input.is_action_just_pressed("detach"):
		has_detached = true
		await get_tree().create_timer(3.0).timeout
		if tutorial_active:
			next_step()

func show_aim() -> void:
	instruction_label.text = "AIMING"
	hint_label.text = "Use IJKL or Arrow Keys while holding SHIFT to aim your shot."
	progress_label.text = "Step 6/9"

func check_aiming() -> void:
	if Input.is_action_pressed("aim-up") or Input.is_action_pressed("aim-down") or \
	   Input.is_action_pressed("aim-left") or Input.is_action_pressed("aim-right"):
		if not has_aimed:
			has_aimed = true
			await get_tree().create_timer(1.5).timeout
			if tutorial_active:
				next_step()

func show_shoot() -> void:
	instruction_label.text = "SHOOTING"
	hint_label.text = "Press E to shoot in your aimed direction. Hit the slime!"
	progress_label.text = "Step 7/9"
	
	# Spawn an enemy if needed
	if enemy_manager and enemy_manager.get_enemy_count() == 0:
		enemy_manager.spawn_enemy()

func check_shooting() -> void:
	if Input.is_action_just_pressed("attack"):
		has_shot = true
		await get_tree().create_timer(3.0).timeout
		if tutorial_active:
			next_step()

func show_powerup_explanation() -> void:
	instruction_label.text = "POWER-UPS"
	hint_label.text = "Capture 6 or more gems at once to spawn a power-up!\nPower-ups give you special abilities for a limited time."
	progress_label.text = "Step 8/9"
	
	await get_tree().create_timer(5.0).timeout
	if tutorial_active:
		next_step()

func show_stomp_demo() -> void:
	instruction_label.text = "STOMP POWER-UP"
	hint_label.text = "This red boot lets you walk through enemies to kill them!\nCollect it and try it out!"
	progress_label.text = "Step 9/9"
	
	if pickup_manager:
		var stomp_scene = load("res://scenes/stomp.tscn")
		if stomp_scene:
			var stomp = stomp_scene.instantiate()
			stomp.position = player.position + Vector2(64, 0)
			game_manager.add_child(stomp)
	
	if enemy_manager:
		enemy_manager.spawn_enemy()
	
	await get_tree().create_timer(8.0).timeout
	if tutorial_active:
		next_step()

func complete_tutorial() -> void:
	instruction_label.text = "TUTORIAL COMPLETE!"
	hint_label.text = "You're ready to survive! Good luck in the Magic Garden!"
	progress_label.text = "Complete!"
	
	await get_tree().create_timer(3.0).timeout
	finish_tutorial()

func next_step() -> void:
	current_step = TutorialStep.values()[current_step + 1] as TutorialStep
	show_step()

func finish_tutorial() -> void:
	tutorial_active = false
	
	tutorial_save.show_tutorial = false
	ResourceSaver.save(tutorial_save, "user://tutorial.tres")
	
	get_tree().paused = false
	if game_manager:
		game_manager.set_process_input(true)
	if enemy_manager:
		enemy_manager.start_enemy_systems()
	if capture_point_manager:
		capture_point_manager.start_capture_systems()
	
	tutorial_finished.emit()
	queue_free()

func _on_skip_pressed() -> void:
	var confirmation = await show_skip_confirmation()
	if confirmation:
		finish_tutorial()

func show_skip_confirmation() -> bool:
	return true

func _input(event: InputEvent) -> void:
	if tutorial_active and event.is_action_pressed("ui_cancel"):
		_on_skip_pressed()
