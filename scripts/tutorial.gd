extends Control

var tutorial_save: TutorialSave

@onready var instruction_label: Label = $TutorialPanel/MarginContainer/VBoxContainer/InstructionLabel
@onready var hint_label: Label = $TutorialPanel/MarginContainer/VBoxContainer/HintLabel
@onready var progress_label: Label = $TutorialPanel/MarginContainer/VBoxContainer/ProgressLabel
@onready var skip_button: Button = $TutorialPanel/MarginContainer/VBoxContainer/SkipButton

# Managers
var game_manager: Node2D
var player: CharacterBody2D
var trail_manager: TrailManager
var enemy_manager: EnemyManager
var capture_manager: CapturePointManager

# Scene Preloads
var yoyo_scene = preload("res://scenes/yoyo.tscn")
var stomp_scene = preload("res://scenes/powerups/stomp.tscn")
var capture_point_scene = preload("res://scenes/capture_point.tscn")

enum TutorialStep {
	WELCOME,
	MOVEMENT,
	SPAWN_GEM,
	PICKUP_GEM,
	SPAWN_CAPTURE,
	CAPTURE_GEM,
	SPAWN_GEM_FOR_ENEMY,
	PICKUP_GEM_FOR_ENEMY,
	MAKE_ENEMY,
	KILL_ENEMY,
	SPAWN_POWERUP,
	COLLECT_POWERUP,
	COMPLETE
}

var current_step: TutorialStep = TutorialStep.WELCOME
var tutorial_active: bool = false
var is_using_controller: bool = false 

# Hardcoded Positions (Based on 12x12 Grid, 32px tiles)
# Center of map is approx 192, 192
var start_pos = Vector2(176, 176) # Center Tile
var right_pos = Vector2(240, 176) # 2 Tiles Right
var left_pos = Vector2(112, 176)  # 2 Tiles Left
var top_pos = Vector2(176, 112)   # 2 Tiles Up

# State Tracking
var has_moved: bool = false
var has_picked_up_gem: bool = false
var enemies_spawned_by_trail: int = 0
var capture_points_created: Array[Node] = []

signal tutorial_finished

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Check for controller immediately
	if Input.get_connected_joypads().size() > 0:
		is_using_controller = true
	
	# Get References
	game_manager = get_node_or_null("/root/MagicGarden/GameManager")
	player = get_node_or_null("/root/MagicGarden/Player")
	trail_manager = get_node_or_null("/root/MagicGarden/TrailManager")
	enemy_manager = get_node_or_null("/root/MagicGarden/EnemyManager")
	capture_manager = get_node_or_null("/root/MagicGarden/CapturePointManager")
	
	# Connect Signals
	if trail_manager:
		trail_manager.trail_item_converted_to_ammo.connect(_on_trail_converted_to_ammo)
		trail_manager.trail_item_converted_to_enemy.connect(_on_trail_converted_to_enemy)
	
	# Load Save Data
	var tutorial_path = "user://tutorial.tres"
	if FileAccess.file_exists(tutorial_path):
		tutorial_save = load(tutorial_path)
	if tutorial_save == null:
		tutorial_save = TutorialSave.new()
	
	if tutorial_save.show_tutorial:
		start_tutorial_logic()
	else:
		tutorial_finished.emit()
		queue_free()
		
	if skip_button:
		skip_button.pressed.connect(_on_skip_pressed)

func start_tutorial_logic() -> void:
	tutorial_active = true
	show()
	
	if game_manager and player:
		# 1. Teleport Player to Center (Safety First)
		player.position = start_pos
		
		# 2. Manual Game Start
		# We set game_started to true so inputs work...
		game_manager.game_started = true
		# ...but we ONLY start the move timer. We do NOT call start_game().
		# This prevents the GameManager from starting the Enemy/Capture timers.
		game_manager.move_timer.start()
		
		# 3. Double check systems are off
		if capture_manager: capture_manager.stop_capture_systems()
		if enemy_manager: enemy_manager.stop_enemy_systems()

	current_step = TutorialStep.WELCOME
	show_step()

func _input(event: InputEvent) -> void:
	if not tutorial_active: return

	# Simple Input Switching
	if event is InputEventJoypadMotion:
		if abs(event.axis_value) > 0.5 and not is_using_controller:
			is_using_controller = true
			refresh_step_text()
	elif event is InputEventJoypadButton:
		if event.pressed and not is_using_controller:
			is_using_controller = true
			refresh_step_text()
	elif (event is InputEventKey or event is InputEventMouseButton) and is_using_controller:
		is_using_controller = false
		refresh_step_text()
	
	if event.is_action_pressed("ui_cancel"):
		_on_skip_pressed()

func show_step() -> void:
	var inputs = get_input_strings()
	
	match current_step:
		TutorialStep.WELCOME:
			set_text("Welcome to Magic Garden!", "Let's learn how to survive.", "1/10")
			await get_tree().create_timer(3.0).timeout
			if check_step(TutorialStep.WELCOME): next_step()

		TutorialStep.MOVEMENT:
			set_text("MOVEMENT", "Use %s to move." % inputs.move, "2/10")

		TutorialStep.SPAWN_GEM:
			spawn_item(yoyo_scene, right_pos) # Fixed Position Right
			next_step()

		TutorialStep.PICKUP_GEM:
			set_text("COLLECT GEMS", "Walk over the blue gem to pick it up.", "3/10")

		TutorialStep.SPAWN_CAPTURE:
			spawn_capture_points(left_pos) # Fixed Position Left
			next_step()

		TutorialStep.CAPTURE_GEM:
			set_text("CAPTURE GEMS", "Stand on the GLOWING TILES and Press %s." % inputs.detach, "4/10")
			hint_label.text = "Gems must be ON the tiles when you detach!"

		TutorialStep.SPAWN_GEM_FOR_ENEMY:
			await get_tree().create_timer(1.0).timeout
			cleanup_capture_points()
			spawn_item(yoyo_scene, right_pos) # Reuse Right Position
			next_step()
			
		TutorialStep.PICKUP_GEM_FOR_ENEMY:
			has_picked_up_gem = false 
			set_text("RELOAD", "Pick up this new gem.", "5/10")

		TutorialStep.MAKE_ENEMY:
			set_text("CREATE TRAPS", "Stand AWAY from points and Press %s." % inputs.detach, "6/10")
			hint_label.text = "Gems NOT on capture points turn into Slimes!"

		TutorialStep.KILL_ENEMY:
			set_text("COMBAT", "A Slime appeared! Aim with %s and Shoot with %s" % [inputs.aim, inputs.shoot], "7/10")
		
		TutorialStep.SPAWN_POWERUP:
			spawn_item(stomp_scene, top_pos) # Fixed Position Up
			next_step()
			
		TutorialStep.COLLECT_POWERUP:
			set_text("POWERUPS", "Collect the Stomp Powerup!", "8/10")
			hint_label.text = "Powerups spawn when you capture 6+ gems at once."

		TutorialStep.COMPLETE:
			set_text("TUTORIAL COMPLETE!", "You're ready! Good luck!", "Complete!")
			await get_tree().create_timer(3.0).timeout
			finish_tutorial()

# --- SPAWNING HELPERS ---

func spawn_item(scene, pos: Vector2) -> void:
	if not scene: return
	var instance = scene.instantiate()
	instance.position = pos
	game_manager.call_deferred("add_child", instance)

func spawn_capture_points(pos: Vector2) -> void:
	# Spawn a 2x1 vertical bar of capture points
	for i in range(2):
		var cp = capture_point_scene.instantiate()
		cp.position = pos + Vector2(0, i * 32)
		game_manager.add_child(cp)
		capture_points_created.append(cp)
		if cp.sprite_frames.has_animation("blue"):
			cp.play("blue")

func cleanup_capture_points() -> void:
	for cp in capture_points_created:
		if is_instance_valid(cp):
			cp.queue_free()
	capture_points_created.clear()

# --- LOGIC UPDATES ---

func _process(_delta: float) -> void:
	if not tutorial_active: return
	
	match current_step:
		TutorialStep.MOVEMENT:
			# Check distance from the hardcoded start_pos
			if player.position.distance_to(start_pos) > 10.0:
				next_step()
		
		TutorialStep.PICKUP_GEM:
			if trail_manager.get_trail_size() > 0:
				next_step()
				
		TutorialStep.PICKUP_GEM_FOR_ENEMY:
			if trail_manager.get_trail_size() > 0:
				next_step()
		
		TutorialStep.KILL_ENEMY:
			if enemy_manager.get_enemy_count() == 0 and enemies_spawned_by_trail > 0:
				next_step()
		
		TutorialStep.COLLECT_POWERUP:
			# If player collected it (it's gone), move on
			if game_manager.get_node_or_null("Stomp") == null: 
				# Note: This relies on the pickup deleting itself. 
				# Better to check if powerup manager has it active:
				if get_node("/root/MagicGarden/PowerupManager").is_stomp_active():
					next_step()

func _on_trail_converted_to_ammo(_streak, _pos):
	if current_step == TutorialStep.CAPTURE_GEM:
		AudioManager.play_sound(game_manager.pickup_sfx)
		next_step()
	elif current_step == TutorialStep.MAKE_ENEMY:
		set_text("OOPS!", "You captured it! Try again.", "Retrying...")
		await get_tree().create_timer(2.0).timeout
		current_step = TutorialStep.SPAWN_GEM_FOR_ENEMY
		show_step()

func _on_trail_converted_to_enemy(_pos):
	if current_step == TutorialStep.MAKE_ENEMY:
		enemies_spawned_by_trail += 1
		next_step()

# --- UTILITIES ---

func check_step(step: TutorialStep) -> bool:
	return tutorial_active and current_step == step

func next_step() -> void:
	if current_step == TutorialStep.COMPLETE: return
	current_step = TutorialStep.values()[current_step + 1] as TutorialStep
	show_step()

func refresh_step_text() -> void:
	show_step()

func set_text(instr: String, hint: String, prog: String) -> void:
	instruction_label.text = instr
	hint_label.text = hint
	progress_label.text = prog

func get_input_strings() -> Dictionary:
	if is_using_controller:
		return {
			"move": "Left Stick",
			"detach": "Button East (B/Circle)",
			"aim": "Right Stick",
			"shoot": "Right Trigger"
		}
	else:
		return {
			"move": "WASD",
			"detach": "E or Space",
			"aim": "Arrows",
			"shoot": "Space"
		}

func finish_tutorial() -> void:
	cleanup_capture_points()
	tutorial_active = false
	tutorial_save.show_tutorial = false
	ResourceSaver.save(tutorial_save, "user://tutorial.tres")
	
	# NOW we start the real game chaos
	if game_manager:
		if capture_manager: capture_manager.start_capture_systems()
		if enemy_manager: enemy_manager.start_enemy_systems()
		game_manager.time_counter.start()
		
	tutorial_finished.emit()
	queue_free()

func _on_skip_pressed() -> void:
	finish_tutorial()
