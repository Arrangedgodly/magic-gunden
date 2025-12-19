extends Control
class_name Tutorial

var tutorial_save: TutorialSave

@onready var instruction_label: Label = %InstructionLabel
@onready var hint_label: RichTextLabel = %HintLabel
@onready var progress_label: Label = %ProgressLabel
@onready var skip_button: Button = %SkipButton
@onready var background: Panel = $TutorialPanel

@export var tutorial_music: AudioStream
@export var pickup_sfx: AudioStream
@export var capture_sfx: AudioStream

var game_manager: Node2D
var player: CharacterBody2D
var trail_manager: TrailManager
var enemy_manager: EnemyManager
var capture_manager: CapturePointManager
var pickup_manager: PickupManager
var powerup_manager: PowerupManager

var stomp_scene = preload("res://scenes/powerups/stomp.tscn")

enum TutorialStep {
	WELCOME,
	MOVEMENT,
	SPAWN_GEM,
	PICKUP_GEM,
	EXPLAIN_CAPTURE_ZONES,
	CAPTURE_GEM,
	EXPLAIN_CAPTURE_MOVEMENT,
	SPAWN_GEM_FOR_ENEMY,
	PICKUP_GEM_FOR_ENEMY,
	MOVE_AWAY_FROM_CAPTURE,
	MAKE_ENEMY,
	ENEMY_MOVEMENT_EXPLANATION,
	AIM_AT_ENEMY,
	KILL_ENEMY,
	SPAWN_POWERUP,
	COLLECT_POWERUP,
	TEST_POWERUP,
	FINAL_EXPLANATION,
	COMPLETE
}

var current_step: TutorialStep = TutorialStep.WELCOME
var tutorial_active: bool = false
var controller_type: String
var has_moved: bool = false
var has_aimed: bool = false
var enemies_spawned_by_trail: int = 0
var test_enemies_killed: int = 0
var waiting_for_continue: bool = false
var tutorial_spawned_yoyo: Node = null
var tutorial_spawned_powerup: Node = null
var should_wait: bool = false

signal tutorial_finished

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	self.z_index = 300
	
	controller_type = ControllerManager.get_controller_type_name()

	game_manager = get_node_or_null("/root/MagicGarden/Systems/GameManager")
	player = get_node_or_null("/root/MagicGarden/World/GameplayArea/Player")
	trail_manager = get_node_or_null("/root/MagicGarden/Systems/TrailManager")
	enemy_manager = get_node_or_null("/root/MagicGarden/Systems/EnemyManager")
	capture_manager = get_node_or_null("/root/MagicGarden/Systems/CapturePointManager")
	pickup_manager = get_node_or_null("/root/MagicGarden/Systems/PickupManager")
	powerup_manager = get_node_or_null("/root/MagicGarden/Systems/PowerupManager")

	if trail_manager:
		trail_manager.trail_item_converted_to_ammo.connect(_on_trail_converted_to_ammo)
		trail_manager.trail_item_converted_to_enemy.connect(_on_trail_converted_to_enemy)
		trail_manager.enemy_convert_blocked.connect(_on_enemy_convert_blocked)
	
	if enemy_manager:
		enemy_manager.slime_killed.connect(_on_test_enemy_killed)

	var tutorial_path = "user://tutorial.tres"
	if FileAccess.file_exists(tutorial_path):
		tutorial_save = load(tutorial_path)
	if tutorial_save == null:
		tutorial_save = TutorialSave.new()
	
	if tutorial_save.show_tutorial:
		start_tutorial_logic()
		AudioManager.play_music(tutorial_music)
	else:
		AudioManager.stop(tutorial_music)
		tutorial_finished.emit()
		queue_free()
		
	if skip_button:
		skip_button.pressed.connect(_on_skip_pressed)
		update_skip_button_text()

func start_tutorial_logic() -> void:
	tutorial_active = true
	show()

	await get_tree().process_frame
	
	if game_manager and player:
		game_manager.is_tutorial_mode = true
		game_manager.tutorial_mode_active = true
		
		if pickup_manager:
			pickup_manager.enable_tutorial_mode()

		if capture_manager:
			capture_manager.enable_tutorial_mode()

		if enemy_manager:
			enemy_manager.enable_tutorial_mode()
		
		if trail_manager:
			trail_manager.tutorial_mode = true

		game_manager.game_started = true
		game_manager.move_timer.start()

	current_step = TutorialStep.WELCOME
	show_step()

func _input(event: InputEvent) -> void:
	if not tutorial_active: 
		return

	if waiting_for_continue:
		return

	if event.is_action_pressed("move-up") or event.is_action_pressed("move-down") or \
	   event.is_action_pressed("move-left") or event.is_action_pressed("move-right"):
		has_moved = true

	if event.is_action_pressed("skip"):
		_on_skip_pressed()

func pause_and_wait() -> void:
	waiting_for_continue = true
	_show_tutorial()

	hint_label.prompt_continue()

	while waiting_for_continue:
		await get_tree().process_frame

func show_step() -> void:
	var total_steps = 18
	
	match current_step:
		TutorialStep.WELCOME:
			get_tree().paused = true
			instruction_label.text = "Welcome to Magic Garden!"
			hint_label.welcome()
			progress_label.text = "Step 1/%d" % total_steps
			await pause_and_wait()
			next_step()

		TutorialStep.MOVEMENT:
			instruction_label.text = "MOVEMENT"
			hint_label.movement()
			progress_label.text = "Step 2/%d" % total_steps
			should_wait = true
			await pause_and_wait()

		TutorialStep.SPAWN_GEM:
			cleanup_tutorial_spawns()
			spawn_gem_near_player()
			next_step()

		TutorialStep.PICKUP_GEM:
			_show_tutorial()
			instruction_label.text = "COLLECT GEMS"
			hint_label.gem_pickup()
			AudioManager.play_sound(pickup_sfx)
			progress_label.text = "Step 3/%d" % total_steps
			should_wait = true
			await pause_and_wait()

		TutorialStep.EXPLAIN_CAPTURE_ZONES:
			_show_tutorial()
			instruction_label.text = "CAPTURE ZONES"
			hint_label.capture_zones()
			AudioManager.play_sound(capture_sfx)
			progress_label.text = "Step 4/%d" % total_steps
			await pause_and_wait()
			next_step()

		TutorialStep.CAPTURE_GEM:
			instruction_label.text = "GET AMMO"
			hint_label.capture_gems()
			progress_label.text = "Step 5/%d" % total_steps
			await pause_and_wait()
			
		TutorialStep.EXPLAIN_CAPTURE_MOVEMENT:
			instruction_label.text = "ZONES MOVE"
			hint_label.zone_movement()
			progress_label.text = "Step 6/%d" % total_steps
			await pause_and_wait()
			
			if capture_manager:
				for i in range(3):
					capture_manager.flash_capture_points()
					await get_tree().create_timer(0.5).timeout
				
				await get_tree().create_timer(1.0).timeout
				
				capture_manager.clear_capture_points()
				var spawn_point = capture_manager.find_capture_spawn_point()
				capture_manager.spawn_capture_points(spawn_point)
				
				next_step()

		TutorialStep.SPAWN_GEM_FOR_ENEMY:
			await get_tree().create_timer(0.5).timeout
			cleanup_tutorial_spawns()
			spawn_gem_near_player()
			next_step()
			
		TutorialStep.PICKUP_GEM_FOR_ENEMY:
			instruction_label.text = "RELOAD"
			hint_label.enemy_gem()
			progress_label.text = "Step 7/%d" % total_steps
			await pause_and_wait()

		TutorialStep.MOVE_AWAY_FROM_CAPTURE:
			instruction_label.text = "MOVE AWAY"
			hint_label.leave_capture()
			progress_label.text = "Step 8/%d" % total_steps
			await pause_and_wait()

		TutorialStep.MAKE_ENEMY:
			instruction_label.text = "CREATE ENEMIES"
			hint_label.create_enemy()
			progress_label.text = "Step 9/%d" % total_steps
			await pause_and_wait()

		TutorialStep.ENEMY_MOVEMENT_EXPLANATION:
			instruction_label.text = "ENEMY BEHAVIOR"
			hint_label.enemy_movement()
			progress_label.text = "Step 10/%d" % total_steps
			await pause_and_wait()
						
			if enemy_manager:
				enemy_manager.move_all_enemies()
			
			await get_tree().create_timer(1.5).timeout
			next_step()

		TutorialStep.AIM_AT_ENEMY:
			instruction_label.text = "AIMING"
			hint_label.aiming()
			progress_label.text = "Step 11/%d" % total_steps
			await pause_and_wait()

		TutorialStep.KILL_ENEMY:
			instruction_label.text = "ATTACK"
			hint_label.kill_enemy()
			progress_label.text = "Step 12/%d" % total_steps
			await pause_and_wait()

		TutorialStep.SPAWN_POWERUP:
			spawn_powerup_near_player()
			await get_tree().create_timer(0.3).timeout
			next_step()

		TutorialStep.COLLECT_POWERUP:
			instruction_label.text = "POWERUPS"
			hint_label.stomp_powerup()
			progress_label.text = "Step 13/%d" % total_steps
			await pause_and_wait()

		TutorialStep.TEST_POWERUP:
			instruction_label.text = "TEST STOMP"
			hint_label.test_powerup()
			progress_label.text = "Step 14/%d" % total_steps
			spawn_test_enemies(5)
			await pause_and_wait()

		TutorialStep.FINAL_EXPLANATION:
			instruction_label.text = "TUTORIAL COMPLETE!"
			hint_label.final()
			progress_label.text = "Step 15/%d" % total_steps
			await pause_and_wait()
			next_step()

		TutorialStep.COMPLETE:
			finish_tutorial()

func spawn_gem_near_player() -> void:
	if not game_manager or not player or not pickup_manager:
		return
	
	pickup_manager.spawn_gem()

func spawn_powerup_near_player() -> void:
	if not pickup_manager:
		return

	pickup_manager.force_spawn_pickup(stomp_scene)

func spawn_test_enemies(count: int) -> void:
	if not enemy_manager:
		return

	for i in range(count):
		await get_tree().create_timer(0.3).timeout
		enemy_manager.spawn_enemy()

func cleanup_tutorial_spawns() -> void:
	tutorial_spawned_yoyo = null
	tutorial_spawned_powerup = null

func _process(_delta: float) -> void:
	if waiting_for_continue:
		if Input.is_action_just_pressed("ui_accept"):
			_hide_tutorial()
			get_tree().paused = false
			if should_wait:
				await get_tree().create_timer(2.0).timeout
				should_wait = false
			waiting_for_continue = false
		return
	
	if not tutorial_active: 
		return
	
	match current_step:
		TutorialStep.MOVEMENT:
			if has_moved:
				next_step()
		
		TutorialStep.PICKUP_GEM:
			if trail_manager.get_trail_size() > 0:
				next_step()
				
		TutorialStep.PICKUP_GEM_FOR_ENEMY:
			if trail_manager.get_trail_size() > 0:
				next_step()
		
		TutorialStep.MOVE_AWAY_FROM_CAPTURE:
			var capture_points = get_tree().get_nodes_in_group("capture")
			var min_distance = INF
			for cp in capture_points:
				if is_instance_valid(cp):
					var dist = player.position.distance_to(cp.position)
					min_distance = min(min_distance, dist)
			
			if min_distance > 64.0:
				next_step()
		
		TutorialStep.AIM_AT_ENEMY:
			if game_manager.aim_direction != Vector2(0, 1):
				has_aimed = true
				next_step()
		
		TutorialStep.KILL_ENEMY:
			if enemy_manager.get_enemy_count() == 0 and enemies_spawned_by_trail > 0:
				next_step()
		
		TutorialStep.COLLECT_POWERUP:
			if powerup_manager and powerup_manager.is_stomp_active():
				next_step()
		
		TutorialStep.TEST_POWERUP:
			if test_enemies_killed >= 1:
				next_step()

func _on_trail_converted_to_ammo(_streak, _pos):
	if current_step == TutorialStep.CAPTURE_GEM:
		trail_manager.tutorial_capture = true
		await get_tree().create_timer(0.5).timeout

		if capture_manager:
			capture_manager.clear_capture_points()
			var spawn_point = capture_manager.find_capture_spawn_point()
			capture_manager.spawn_capture_points(spawn_point)
		next_step()

	elif current_step == TutorialStep.MAKE_ENEMY or current_step == TutorialStep.MOVE_AWAY_FROM_CAPTURE:
		if enemies_spawned_by_trail > 0:
			return
		instruction_label.text = "OOPS!"
		hint_label.text = "You captured it! Try stepping off the glowing tiles."
		progress_label.text = "Retrying..."
		_show_tutorial()
		await pause_and_wait()
		current_step = TutorialStep.MAKE_ENEMY
		show_step()

func _on_trail_converted_to_enemy(_pos):
	if current_step != TutorialStep.MAKE_ENEMY:
		return
		
	enemies_spawned_by_trail += 1

	await get_tree().create_timer(0.1).timeout

	next_step()

func _on_test_enemy_killed() -> void:
	if current_step == TutorialStep.TEST_POWERUP:
		test_enemies_killed += 1

func check_step(step: TutorialStep) -> bool:
	return tutorial_active and current_step == step

func next_step() -> void:
	if current_step == TutorialStep.COMPLETE: 
		return
	current_step = TutorialStep.values()[current_step + 1] as TutorialStep
	show_step()

func refresh_step_text() -> void:
	show_step()

func update_skip_button_text() -> void:
	if not skip_button:
		return
	
	if controller_type == "Xbox" or controller_type == "Steam Deck":
		skip_button.text = "Skip Tutorial (B)"
	elif controller_type == "Playstation":
		skip_button.text = "Skip Tutorial (Circle)"
	else:
		skip_button.text = "Skip Tutorial (T)"

func finish_tutorial() -> void:
	cleanup_tutorial_spawns()
	
	tutorial_active = false
	tutorial_save.show_tutorial = false
	ResourceSaver.save(tutorial_save, "user://tutorial.tres")

	if pickup_manager:
		pickup_manager.regen_yoyo = true
	
	if capture_manager:
		capture_manager.clear_capture_points()
		capture_manager.disable_tutorial_mode()

		var spawn_point = capture_manager.find_capture_spawn_point()
		capture_manager.spawn_capture_points(spawn_point)

	if game_manager:
		game_manager.start_normal_gameplay_loop()
	
	if trail_manager:
		trail_manager.tutorial_mode = false
		
	tutorial_finished.emit()
	AudioManager.stop(tutorial_music)
	queue_free()

func _on_skip_pressed() -> void:
	if waiting_for_continue:
		waiting_for_continue = false
		get_tree().paused = false
	
	tutorial_save.show_tutorial = false
	ResourceSaver.save(tutorial_save, "user://tutorial.tres")
	
	finish_tutorial()

func _on_enemy_convert_blocked() -> void:
	_show_tutorial()
	progress_label.text = "⚠️ Oops!"
	instruction_label.text = "You missed the capture point!"
	hint_label.enemy_convert_blocked()
	await pause_and_wait()
	

func _show_tutorial() -> void:
	get_tree().paused = true
	self.z_index = 300
	background.show()
	skip_button.show()

func _hide_tutorial() -> void:
	self.z_index = 0
	background.hide()
	skip_button.hide()
