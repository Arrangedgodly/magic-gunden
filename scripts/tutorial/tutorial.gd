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

var game_manager
var player
var trail_manager
var enemy_manager
var capture_manager
var pickup_manager
var powerup_manager
var ammo_manager

var tutorial_steps: Array[TutorialStep] = []
var current_step_index: int = 0
var current_step: TutorialStep = null
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

const WelcomeStep = preload("res://scripts/tutorial/steps/welcome.gd")
const MovementStep = preload("res://scripts/tutorial/steps/movement_step.gd")
const SpawnGemStep = preload("res://scripts/tutorial/steps/spawn_gem.gd")
const PickupGemStep = preload("res://scripts/tutorial/steps/pickup_gem.gd")
const ExplainCaptureZonesStep = preload("res://scripts/tutorial/steps/explain_capture_zones.gd")
const CaptureGemStep = preload("res://scripts/tutorial/steps/capture_gem.gd")
const ExplainCaptureMovementStep = preload("res://scripts/tutorial/steps/explain_capture_movement.gd")
const SpawnGemsForCaptureLessonStep = preload("res://scripts/tutorial/steps/spawn_gems_for_capture_lesson.gd")
const AttemptCaptureStep = preload("res://scripts/tutorial/steps/attempt_capture.gd")
const ExplainEnemySpawnStep = preload("res://scripts/tutorial/steps/explain_enemy_spawn.gd")
const EnemyMovementExplanationStep = preload("res://scripts/tutorial/steps/enemy_movement.gd")
const AimAtEnemyStep = preload("res://scripts/tutorial/steps/aim_at_enemy.gd")
const KillEnemyStep = preload("res://scripts/tutorial/steps/kill_enemy.gd")
const SpawnPowerupStep = preload("res://scripts/tutorial/steps/spawn_powerup.gd")
const CollectPowerupStep = preload("res://scripts/tutorial/steps/collect_powerup.gd")
const TestPowerupStep = preload("res://scripts/tutorial/steps/test_powerup.gd")
const FinalExplanationStep = preload("res://scripts/tutorial/steps/final_explanation.gd")

signal can_fire
signal tutorial_finished

func _ready() -> void:
	DebugLogger.log_info("=== TUTORIAL READY START ===")
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	await get_tree().process_frame
	
	self.z_index = 300
	
	controller_type = ControllerManager.get_controller_type_name()
	DebugLogger.log_info("Controller type: " + controller_type)

	DebugLogger.log_info("Getting node references...")

	game_manager = get_node_or_null("/root/MagicGarden/Systems/GameManager")
	player = get_node_or_null("/root/MagicGarden/World/GameplayArea/Player")
	trail_manager = get_node_or_null("/root/MagicGarden/Systems/TrailManager")
	enemy_manager = get_node_or_null("/root/MagicGarden/Systems/EnemyManager")
	capture_manager = get_node_or_null("/root/MagicGarden/Systems/CapturePointManager")
	pickup_manager = get_node_or_null("/root/MagicGarden/Systems/PickupManager")
	powerup_manager = get_node_or_null("/root/MagicGarden/Systems/PowerupManager")
	ammo_manager = get_node_or_null("/root/MagicGarden/Systems/AmmoManager")
	
	DebugLogger.log_info("Nodes found - GM: " + str(game_manager != null) + 
						  ", Player: " + str(player != null) + 
						  ", Trail: " + str(trail_manager != null))
	
	DebugLogger.log_info("Connecting trail manager signals...")
	if trail_manager:
		if trail_manager.has_signal("enemy_convert_blocked"):
			trail_manager.enemy_convert_blocked.connect(_on_enemy_convert_blocked)
		else:
			DebugLogger.log_error("CRITICAL: TrailManager Node found, but signal 'enemy_convert_blocked' is missing! Script may have failed to load.")
	
	DebugLogger.log_info("Connecting enemy manager signals...")
	if enemy_manager:
		enemy_manager.slime_killed.connect(_on_test_enemy_killed)
		enemy_manager.enemy_spawned.connect(_on_enemy_spawned_for_tutorial)
	
	DebugLogger.log_info("Connecting game manager signals...")
	if game_manager:
		game_manager.tutorial_player_died.connect(_on_tutorial_player_died)
		game_manager.child_entered_tree.connect(_on_game_manager_child_added)
	
	DebugLogger.log_info("Getting killzones...")
	var killzones = get_tree().get_nodes_in_group("killzone")
	DebugLogger.log_info("Found " + str(killzones.size()) + " killzones")
	for kz in killzones:
		if not kz.player_fell_off_map.is_connected(_on_killzone_triggered):
			kz.player_fell_off_map.connect(_on_killzone_triggered)
	
	DebugLogger.log_info("Connecting player signals...")
	if player:
		player.child_entered_tree.connect(_on_player_child_added)
	
	tutorial_save = SaveHelper.load_tutorial_save()
	
	DebugLogger.log_info("Tutorial save show_tutorial: " + str(tutorial_save.show_tutorial))
	
	DebugLogger.log_info("Initializing tutorial steps...")
	_initialize_steps()
	
	if tutorial_save.show_tutorial:
		DebugLogger.log_info("Starting tutorial logic...")
		start_tutorial_logic()
		AudioManager.play_music(tutorial_music)
	else:
		DebugLogger.log_info("Skipping tutorial, emitting finished signal...")
		AudioManager.stop(tutorial_music)
		tutorial_finished.emit()
		queue_free()
	
	if skip_button:
		skip_button.pressed.connect(_on_skip_pressed)
		update_skip_button_text()
	
	DebugLogger.log_info("=== TUTORIAL READY COMPLETE ===")

func _initialize_steps() -> void:
	DebugLogger.log_info("--- STEP INIT START ---")
	tutorial_steps.clear()
	
	DebugLogger.log_info("1. Creating WelcomeStep...")
	tutorial_steps.append(WelcomeStep.new(self))
	
	DebugLogger.log_info("2. Creating MovementStep...")
	tutorial_steps.append(MovementStep.new(self))
	
	DebugLogger.log_info("3. Creating SpawnGemStep...")
	tutorial_steps.append(SpawnGemStep.new(self))
	
	DebugLogger.log_info("4. Creating PickupGemStep...")
	tutorial_steps.append(PickupGemStep.new(self))
	
	DebugLogger.log_info("5. Creating ExplainCaptureZonesStep...")
	tutorial_steps.append(ExplainCaptureZonesStep.new(self))
	
	DebugLogger.log_info("6. Creating CaptureGemStep...")
	tutorial_steps.append(CaptureGemStep.new(self))
	
	DebugLogger.log_info("7. Creating ExplainCaptureMovementStep...")
	tutorial_steps.append(ExplainCaptureMovementStep.new(self))
	
	DebugLogger.log_info("8. Creating SpawnGemsForCaptureLessonStep...")
	tutorial_steps.append(SpawnGemsForCaptureLessonStep.new(self))
	
	DebugLogger.log_info("9. Creating AttemptCaptureStep...")
	tutorial_steps.append(AttemptCaptureStep.new(self))
	
	DebugLogger.log_info("10. Creating ExplainEnemySpawnStep...")
	tutorial_steps.append(ExplainEnemySpawnStep.new(self))
	
	DebugLogger.log_info("11. Creating EnemyMovementExplanationStep...")
	tutorial_steps.append(EnemyMovementExplanationStep.new(self))
	
	DebugLogger.log_info("12. Creating AimAtEnemyStep...")
	tutorial_steps.append(AimAtEnemyStep.new(self))
	
	DebugLogger.log_info("13. Creating KillEnemyStep...")
	tutorial_steps.append(KillEnemyStep.new(self))
	
	DebugLogger.log_info("14. Creating SpawnPowerupStep...")
	tutorial_steps.append(SpawnPowerupStep.new(self))
	
	DebugLogger.log_info("15. Creating CollectPowerupStep...")
	tutorial_steps.append(CollectPowerupStep.new(self))
	
	DebugLogger.log_info("16. Creating TestPowerupStep...")
	tutorial_steps.append(TestPowerupStep.new(self))
	
	DebugLogger.log_info("17. Creating FinalExplanationStep...")
	tutorial_steps.append(FinalExplanationStep.new(self))
	
	DebugLogger.log_info("--- STEP INIT COMPLETE ---")

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
		else:
			DebugLogger.log_error("Pickup manager is null")

		if capture_manager:
			capture_manager.enable_tutorial_mode()
		else:
			DebugLogger.log_error("Capture manager is null")

		if enemy_manager:
			enemy_manager.enable_tutorial_mode()
		else:
			DebugLogger.log_error("Enemy manager is null")
		
		if trail_manager:
			trail_manager.tutorial_mode = true
		else:
			DebugLogger.log_error("Trail manager is null")

		game_manager.game_started = true
		player.move_timer.start()
		player.can_fire = false

	current_step_index = 0
	_execute_current_step()

func _execute_current_step() -> void:
	if current_step_index >= tutorial_steps.size():
		finish_tutorial()
		return

	if current_step:
		current_step.exit()

	current_step = tutorial_steps[current_step_index]
	await current_step.enter()

func _input(event: InputEvent) -> void:
	if not tutorial_active: 
		return
		
	if event.is_action_pressed("skip"):
		_on_skip_pressed()

	if waiting_for_continue:
		var is_touch = (event is InputEventScreenTouch and event.pressed)
		var is_accept_key = event.is_action_pressed("ui_accept")
		
		if is_touch or is_accept_key:
			_hide_tutorial()
			get_tree().paused = false
			waiting_for_continue = false
		return

func _process(_delta: float) -> void:
	if disable_auto_advance:
		return
		
	if not tutorial_active:
		return
	
	if not has_moved:
		var move_input = Input.get_vector("move-left", "move-right", "move-up", "move-down")
		if move_input.length() > 0.1:
			has_moved = true
		
	if current_step and current_step.can_auto_advance:
		if current_step.check_auto_advance():
			next_step()

func _on_test_enemy_killed() -> void:
	test_enemies_killed += 1

func check_step(step: TutorialStep) -> bool:
	return tutorial_active and current_step == step

func next_step() -> void:
	current_step_index += 1
	_execute_current_step()

func cleanup_tutorial_spawns() -> void:
	tutorial_spawned_gem = null
	tutorial_spawned_powerup = null

func update_skip_button_text() -> void:
	if not skip_button:
		return
	
	if DisplayServer.is_touchscreen_available() or OS.has_feature("web_android") or OS.has_feature("web_ios"):
		skip_button.text = "Skip Tutorial"
	
	if controller_type == "Xbox" or controller_type == "Steam Deck":
		skip_button.text = "Skip Tutorial (B)"
	elif controller_type == "Playstation":
		skip_button.text = "Skip Tutorial (Circle)"
	else:
		skip_button.text = "Skip Tutorial (T)"

func finish_tutorial() -> void:
	if get_tree().paused:
		get_tree().paused = false
		
	cleanup_tutorial_spawns()
	
	tutorial_active = false
	tutorial_protection_active = false
	tutorial_save.show_tutorial = false
	SaveHelper.save_tutorial_save(tutorial_save)

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
	
	if not player.can_fire:
		player.can_fire = true
		
	tutorial_finished.emit()
	AudioManager.stop(tutorial_music)
	queue_free()

func _on_skip_pressed() -> void:
	if waiting_for_continue:
		waiting_for_continue = false
	
	get_tree().paused = false
	
	tutorial_save.show_tutorial = false
	SaveHelper.save_tutorial_save(tutorial_save)
	
	finish_tutorial()

func _on_enemy_convert_blocked() -> void:
	_show_tutorial()
	progress_label.text = "⚠️ Oops!"
	instruction_label.text = "You missed the capture point!"
	hint_label.enemy_convert_blocked()
	trail_manager.create_trail_segment()
	
	waiting_for_continue = true
	hint_label.prompt_continue()

	while waiting_for_continue:
		await get_tree().process_frame

func _on_game_manager_child_added(node: Node) -> void:
	if node is Gem:
		node.player_hit_trail.connect(_on_trail_hit_player)
	elif node is Slime:
		if not node.was_killed.is_connected(_on_test_enemy_killed):
			node.was_killed.connect(_on_test_enemy_killed)

func _on_player_child_added(node: Node) -> void:
	if node is Projectile and tutorial_protection_active:
		node.shot_missed.connect(_on_tutorial_shot_missed)

func _on_tutorial_shot_missed() -> void:
	if not tutorial_protection_active:
		return

	_show_tutorial()
	
	progress_label.text = "⚠️ Oops!"
	instruction_label.text = "MISSED SHOT"
	hint_label.shot_missed()
	
	waiting_for_continue = true
	hint_label.prompt_continue()
	
	while waiting_for_continue:
		await get_tree().process_frame
	
	if ammo_manager:
		ammo_manager.increase_ammo_count()

func _on_enemy_spawned_for_tutorial(enemy_node: Node2D) -> void:
	if enemy_node.has_signal("player_hit_by_enemy"):
		enemy_node.player_hit_by_enemy.connect(_on_enemy_hit_player)

func _on_killzone_triggered() -> void:
	current_death_reason = "off_map"

func _on_enemy_hit_player() -> void:
	current_death_reason = "enemy"

func _on_trail_hit_player() -> void:
	current_death_reason = "trail"

func _on_tutorial_player_died() -> void:
	_show_tutorial()
	progress_label.text = "⚠️ Oops!"
	
	if current_death_reason == "trail":
		instruction_label.text = "TRAIL COLLISION"
		hint_label.trail_collision()
	elif current_death_reason == "off_map":
		instruction_label.text = "OFF MAP"
		hint_label.off_map()
	else:
		instruction_label.text = "ENEMY COLLISION"
		hint_label.enemy_collision()
	
	waiting_for_continue = true
	hint_label.prompt_continue()

	while waiting_for_continue:
		await get_tree().process_frame
	
	if player:
		player.reset_to_start()
		
		trail_manager.reset_trail_visuals(player.position)
		
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
