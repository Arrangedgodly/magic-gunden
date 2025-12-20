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
var ammo_manager: AmmoManager

var stomp_scene = preload("res://scenes/powerups/stomp.tscn")

enum TutorialStep {
	WELCOME,
	MOVEMENT,
	SPAWN_GEM,
	PICKUP_GEM,
	EXPLAIN_CAPTURE_ZONES,
	CAPTURE_GEM,
	EXPLAIN_CAPTURE_MOVEMENT,
	SPAWN_GEMS_FOR_CAPTURE_LESSON,
	ATTEMPT_CAPTURE,
	EXPLAIN_ENEMY_SPAWN,
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
var test_enemies_killed: int = 0
var waiting_for_continue: bool = false
var disable_auto_advance: bool = false
var tutorial_spawned_gem: Node = null
var tutorial_spawned_powerup: Node = null
var tutorial_protection_active: bool = false
var missed_capture_explained: bool = false
var should_wait: bool = false
var current_death_reason: String = "enemy"

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
	ammo_manager = get_node_or_null("/root/MagicGarden/Systems/AmmoManager")

	if trail_manager:
		trail_manager.trail_item_converted_to_ammo.connect(_on_trail_converted_to_ammo)
		trail_manager.enemy_convert_blocked.connect(_on_enemy_convert_blocked)
	
	if enemy_manager:
		enemy_manager.slime_killed.connect(_on_test_enemy_killed)
		enemy_manager.enemy_spawned.connect(_on_enemy_spawned_for_tutorial)
	
	if game_manager:
		game_manager.tutorial_player_died.connect(_on_tutorial_player_died)
	
	var killzones = get_tree().get_nodes_in_group("killzone")
	for kz in killzones:
		if not kz.player_fell_off_map.is_connected(_on_killzone_triggered):
			kz.player_fell_off_map.connect(_on_killzone_triggered)
	
	player.child_entered_tree.connect(_on_player_child_added)

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
	reset_tutorial_state()
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
		player.move_timer.start()

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
	disable_auto_advance = true
	var total_steps = 14
	
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
			disable_auto_advance = false

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
			disable_auto_advance = false

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
			disable_auto_advance = false
			
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

		TutorialStep.SPAWN_GEMS_FOR_CAPTURE_LESSON:
			if capture_manager:
				capture_manager.clear_capture_points()
			
			await get_tree().create_timer(0.3).timeout
			if capture_manager:
				capture_manager.tutorial_pattern = true
				var spawn_point = Vector2i(96, 96)
				capture_manager.spawn_capture_points(spawn_point)
			
			await get_tree().create_timer(0.5).timeout
			if trail_manager:
				trail_manager.create_multiple_trail_segments(5)
			
			await get_tree().create_timer(0.5).timeout
			next_step()
			
		TutorialStep.ATTEMPT_CAPTURE:
			instruction_label.text = "CAPTURE PRACTICE"
			hint_label.attempt_capture_practice()
			progress_label.text = "Step 7/%d" % total_steps
			await pause_and_wait()
			disable_auto_advance = false	

		TutorialStep.EXPLAIN_ENEMY_SPAWN:
			capture_manager.tutorial_pattern = false
			instruction_label.text = "ENEMY SPAWNING"
			hint_label.explain_enemy_spawn()
			progress_label.text = "Step 8/%d" % total_steps
			await pause_and_wait()
			next_step()


		TutorialStep.ENEMY_MOVEMENT_EXPLANATION:
			instruction_label.text = "ENEMY BEHAVIOR"
			hint_label.enemy_movement()
			progress_label.text = "Step 9/%d" % total_steps
			await pause_and_wait()
						
			if enemy_manager:
				enemy_manager.move_all_enemies()
			
			await get_tree().create_timer(1.5).timeout
			next_step()

		TutorialStep.AIM_AT_ENEMY:
			instruction_label.text = "AIMING"
			hint_label.aiming()
			progress_label.text = "Step 10/%d" % total_steps
			await pause_and_wait()
			disable_auto_advance = false

		TutorialStep.KILL_ENEMY:
			tutorial_protection_active = true
			instruction_label.text = "ATTACK"
			hint_label.kill_enemy()
			progress_label.text = "Step 11/%d" % total_steps
			await pause_and_wait()
			disable_auto_advance = false

		TutorialStep.SPAWN_POWERUP:
			tutorial_protection_active = false
			spawn_powerup_near_player()
			await get_tree().create_timer(0.3).timeout
			next_step()

		TutorialStep.COLLECT_POWERUP:
			instruction_label.text = "POWERUPS"
			hint_label.stomp_powerup()
			progress_label.text = "Step 12/%d" % total_steps
			await pause_and_wait()
			disable_auto_advance = false

		TutorialStep.TEST_POWERUP:
			instruction_label.text = "TEST STOMP"
			hint_label.test_powerup()
			progress_label.text = "Step 13/%d" % total_steps
			spawn_test_enemies(5)
			await pause_and_wait()
			disable_auto_advance = false

		TutorialStep.FINAL_EXPLANATION:
			instruction_label.text = "TUTORIAL COMPLETE!"
			hint_label.final()
			progress_label.text = "Step 14/%d" % total_steps
			await pause_and_wait()
			next_step()

		TutorialStep.COMPLETE:
			finish_tutorial()

func spawn_gem_near_player() -> void:
	if not game_manager or not player or not pickup_manager:
		return
	
	pickup_manager.force_spawn_gem()

func spawn_powerup_near_player() -> void:
	if not pickup_manager:
		return

	powerup_manager.force_spawn_powerup(stomp_scene)

func spawn_test_enemies(count: int) -> void:
	if not enemy_manager:
		return

	for i in range(count):
		await get_tree().create_timer(0.3).timeout
		enemy_manager.spawn_enemy()

func cleanup_tutorial_spawns() -> void:
	tutorial_spawned_gem = null
	tutorial_spawned_powerup = null

func _process(_delta: float) -> void:
	if waiting_for_continue or disable_auto_advance:
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
				
		TutorialStep.ATTEMPT_CAPTURE:
			if trail_manager.get_trail_size() == 0 and not missed_capture_explained:
				missed_capture_explained = true
				
				await get_tree().create_timer(1.5).timeout
				
				next_step()
		
		TutorialStep.AIM_AT_ENEMY:
			if player and player.aim_direction != Vector2(0, 1):
				has_aimed = true
				next_step()
		
		TutorialStep.KILL_ENEMY:
			if enemy_manager.get_enemy_count() == 0:
				next_step()
		
		TutorialStep.COLLECT_POWERUP:
			if powerup_manager and powerup_manager.is_stomp_active():
				next_step()
		
		TutorialStep.TEST_POWERUP:
			if test_enemies_killed >= 1:
				next_step()

func _on_trail_converted_to_ammo():
	if current_step == TutorialStep.CAPTURE_GEM:
		if trail_manager:
			trail_manager.tutorial_capture = true
		await get_tree().create_timer(0.5).timeout

		if capture_manager:
			capture_manager.clear_capture_points()
			var spawn_point = capture_manager.find_capture_spawn_point()
			capture_manager.spawn_capture_points(spawn_point)
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
	tutorial_protection_active = false
	tutorial_save.show_tutorial = false
	ResourceSaver.save(tutorial_save, "user://tutorial.tres")

	if pickup_manager:
		pickup_manager.regen_gem = true
		pickup_manager.tutorial_mode = false
	
	if capture_manager:
		capture_manager.clear_capture_points()
		capture_manager.disable_tutorial_mode()

		var spawn_point = capture_manager.find_capture_spawn_point()
		capture_manager.spawn_capture_points(spawn_point)

	if game_manager:
		game_manager.start_normal_gameplay_loop()
	
	if trail_manager:
		trail_manager.tutorial_mode = false
		trail_manager.clear_trail()
		
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
	trail_manager.create_trail_segment()
	await pause_and_wait()

func _on_player_child_added(node: Node) -> void:
	if node is Projectile and tutorial_protection_active:
		node.shot_missed.connect(_on_tutorial_shot_missed)

func _on_tutorial_shot_missed() -> void:
	if not tutorial_protection_active or not check_step(TutorialStep.KILL_ENEMY):
		return

	_show_tutorial()
	
	progress_label.text = "⚠️ Oops!"
	instruction_label.text = "MISSED SHOT"
	hint_label.shot_missed()
	
	await pause_and_wait()
	
	if ammo_manager:
		ammo_manager.increase_ammo_count()

func _on_enemy_spawned_for_tutorial(enemy_node: Node2D) -> void:
	if enemy_node.has_signal("player_hit_by_enemy"):
		enemy_node.player_hit_by_enemy.connect(_on_enemy_hit_player)

func _on_killzone_triggered() -> void:
	current_death_reason = "off_map"

func _on_enemy_hit_player() -> void:
	current_death_reason = "enemy"

func _on_tutorial_player_died(reason: String = "") -> void:
	_show_tutorial()
	progress_label.text = "⚠️ Oops!"
	
	if current_death_reason == "off_map":
		instruction_label.text = "OFF MAP"
		hint_label.off_map()
	else:
		instruction_label.text = "ENEMY COLLISION"
		hint_label.enemy_collision()
	
	await pause_and_wait()
	
	if player:
		player.reset_to_start()
		
	current_death_reason = "enemy"

func _show_tutorial() -> void:
	get_tree().paused = true
	self.z_index = 300
	background.show()
	skip_button.show()

func _hide_tutorial() -> void:
	self.z_index = 0
	background.hide()
	skip_button.hide()

func reset_tutorial_state() -> void:
	has_moved = false
	has_aimed = false
	test_enemies_killed = 0
	waiting_for_continue = false
	should_wait = false
	cleanup_tutorial_spawns()

func get_detach_button() -> String:
	if controller_type == "Xbox" or controller_type == "Steam Deck":
		return "X"
	elif controller_type == "Playstation":
		return "Square"
	else:
		return "Space"

func get_attack_button() -> String:
	if controller_type == "Xbox" or controller_type == "Steam Deck":
		return "A"
	elif controller_type == "Playstation":
		return "X"
	else:
		return "Left Mouse / Enter"

func get_aim_buttons() -> String:
	if controller_type == "Xbox" or controller_type == "Playstation" or controller_type == "Steam Deck":
		return "Right Stick"
	else:
		return "IJKL / Right Stick"

func get_continue_button() -> String:
	if controller_type == "Xbox" or controller_type == "Steam Deck":
		return "A"
	elif controller_type == "Playstation":
		return "X"
	else:
		return "Enter / Space"
