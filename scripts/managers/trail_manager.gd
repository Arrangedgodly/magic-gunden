extends Node2D
class_name TrailManager

signal trail_item_converted_to_enemy(position: Vector2)
signal trail_item_converted_to_ammo
signal enemy_convert_blocked

@onready var player: CharacterBody2D = %Player
@onready var game_manager: Node2D = %GameManager
@onready var pickup_manager: PickupManager = %PickupManager
@onready var powerup_manager: PowerupManager = %PowerupManager
@onready var ammo_manager: AmmoManager = %AmmoManager
@onready var score_manager: ScoreManager = %ScoreManager
@onready var capture_point_manager: CapturePointManager = %CapturePointManager

var trail: Array = []
var move_history: Array = []
var pickup_count: int = 0
var capture_count: int = 0
var gem_scene_path: String = "res://scenes/gem.tscn"
var blue_slime_scene_path: String = "res://scenes/blue_slime.tscn"
var tutorial_mode: bool = false
var tutorial_capture: bool = false

const ANIMATION_SPEED = 5
var level: int = 1

func _ready() -> void:
	DebugLogger.log_info("=== TRAIL MANAGER READY START ===")
	if game_manager:
		game_manager.level_changed.connect(_on_level_changed)
	
	if pickup_manager:
		pickup_manager.gem_collected.connect(_on_gem_collected)
	
	DebugLogger.log_info("=== TRAIL MANAGER READY COMPLETE ===")

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("detach"):
		release_trail()

func _on_gem_collected() -> void:
	create_trail_segment()

func update_move_history(current_position: Vector2) -> void:
	DebugLogger.log_info("Updating trail move history...")
	if len(move_history) > pickup_count:
		move_history.pop_front()
	move_history.append(current_position)
	
	activate_trail_collisions()
	DebugLogger.log_info("Trail move history updated successfully!")

func activate_trail_collisions() -> void:
	DebugLogger.log_info("Activating trail collisions...")
	for i in range(trail.size()):
		if i < trail.size() - 1:
			var piece = trail[i]
			if is_instance_valid(piece) and piece.has_method("activate_collision"):
				piece.activate_collision()
			else:
				DebugLogger.log_error("Trail gem not valid or does not have method activate collision")
	
	DebugLogger.log_info("Trail collisions activated successfully!")

func create_trail_segment() -> void:
	DebugLogger.log_info("Creating trail segment...")
	if move_history.is_empty():
		DebugLogger.log_error("No move history found!")
		return
	
	DebugLogger.log_info("Instantiating gem...")
	var gem_scene = load(gem_scene_path)
	var gem_instance = gem_scene.instantiate()
	var last_position = move_history[len(move_history) - 1]
	var local_position = game_manager.to_local(last_position)
	
	gem_instance.position = local_position
	gem_instance.negate_pickup()
	
	match level:
		1: gem_instance.play("blue")
		2: gem_instance.play("green")
		3: gem_instance.play("red")
	
	game_manager.call_deferred("add_child", gem_instance)
	DebugLogger.log_info("Gem added to game manager")
	gem_instance.add_to_group("equipped")
	trail.append(gem_instance)
	pickup_count += 1
	DebugLogger.log_info("Trail segment instantiated successfully!")

func create_multiple_trail_segments(segment_count: int) -> void:
	for i in range(segment_count):
		create_trail_segment()

func move_trail() -> void:
	DebugLogger.log_info("Moving trail...")
	if trail.is_empty():
		DebugLogger.log_info("Trail is empty")
		return
		
	for i in range(len(trail)):
		if i + 1 < len(move_history):
			var target_position = move_history[-(i + 1)]
			var local_position = game_manager.to_local(target_position)
			var tween = game_manager.create_tween()
			tween.tween_property(trail[i], "position", local_position, 1.0/ANIMATION_SPEED).set_trans(Tween.TRANS_SINE)
			trail[i].set_meta("movement_tween", tween)
	
	DebugLogger.log_info("Trail moved successfully!")
	
func release_trail() -> void:
	DebugLogger.log_info("Releasing trail...")
	if trail.is_empty():
		DebugLogger.log_info("Trail is empty")
		_on_trail_released(0)
		return
	
	capture_count = 0
	
	var items_to_convert = []
	
	for i in range(trail.size()):
		var item = trail[i]
		var spawn_pos = item.position
		
		if i < move_history.size():
			var history_pos = move_history[-(i + 1)]
			spawn_pos = game_manager.to_local(history_pos)
		
		var item_data = {
			"node": item,
			"position": spawn_pos,
			"on_capture": is_on_capture_point(item)
		}
		items_to_convert.append(item_data)
		
		if item_data.on_capture:
			capture_count += 1
			item.flash(Color(0, 255, 0, 255))
		else:
			item.flash(Color(255, 0, 0, 255))
	
	var items_captured = capture_count
	
	trail.clear()
	capture_count = 0
	
	await get_tree().create_timer(0.375).timeout
	
	var current_streak = 0
	for item_data in items_to_convert:
		if item_data.on_capture:
			current_streak += 1
			_on_ammo_conversion(current_streak)
		else:
			if tutorial_mode:
				if not tutorial_capture:
					enemy_convert_blocked.emit()
				else:
					_instantiate_enemy(item_data)
			else:
				_instantiate_enemy(item_data)
					
		
		if is_instance_valid(item_data.node):
			item_data.node.queue_free()
	
	_on_trail_released(items_captured)
	
	DebugLogger.log_info("Trail released successfully!")

func _on_trail_released(items_captured: int) -> void:
	DebugLogger.log_info("Checking trail released...")
	if items_captured >= 6:
		powerup_manager.spawn_powerup()
	
	if not powerup_manager.is_time_pause_active():
		capture_point_manager.reset_capture_timers()
	DebugLogger.log_info("Trail release checked successfully!")

func _on_ammo_conversion(streak: int) -> void:
	DebugLogger.log_info("Trail manager initiating ammo conversion...")
	player.create_score_popup(10 * streak)
	
	ammo_manager.increase_ammo_count()
	
	score_manager.saved_game.increase_gems_captured(1)
	score_manager.append_scores_to_add(10 * streak)
	
	trail_item_converted_to_ammo.emit()
	DebugLogger.log_info("Trail manager ammo conversion completed!")

func _instantiate_enemy(item_data) -> void:
	DebugLogger.log_info("Trail manager initiating enemy instantiation...")
	var blue_slime_scene = load(blue_slime_scene_path)
	var enemy_instance = blue_slime_scene.instantiate()
	enemy_instance.position = item_data.position
	game_manager.add_child(enemy_instance)
	DebugLogger.log_info("Enemy added to game manager")
					
	if game_manager.has_method("increase_slimes_killed"):
		enemy_instance.was_killed.connect(game_manager.increase_slimes_killed)
				
	trail_item_converted_to_enemy.emit(item_data.position)
	DebugLogger.log_info("Trail manager enemy instantiation completed!")

func is_on_capture_point(item: Node2D) -> bool:
	var capture_points = game_manager.get_tree().get_nodes_in_group("capture")
	
	for point in capture_points:
		var detected_body = point.check_detected_body()
		if detected_body:
			if detected_body.position == item.position:
				return true
	
	return false

func convert_to_enemy(pickup: Node2D) -> void:
	DebugLogger.log_info("Trail manager converting gem to enemy...")
	await pickup.flash(Color(255, 0, 0, 255))
	
	var blue_slime_scene = load(blue_slime_scene_path)
	var enemy_instance = blue_slime_scene.instantiate()
	enemy_instance.position = pickup.position
	game_manager.add_child(enemy_instance)
	DebugLogger.log_info("Enemy added to game manager")
	
	if game_manager.has_method("increase_slimes_killed"):
		enemy_instance.was_killed.connect(game_manager.increase_slimes_killed)
	
	pickup.queue_free()
	trail_item_converted_to_enemy.emit(pickup.position)
	DebugLogger.log_info("Trail manager converted gem to enemy successfully!")

func convert_to_ammo(pickup: Node2D, streak: int) -> void:
	DebugLogger.log_info("Trail manager converting gem to ammo...")
	await pickup.flash(Color(0, 255, 0, 255))
	
	pickup.queue_free()
	_on_ammo_conversion(streak)
	DebugLogger.log_info("Trail manager converted gem to ammo successfully!")

func get_trail_size() -> int:
	return trail.size()

func has_trail() -> bool:
	return not trail.is_empty()

func get_first_trail_position() -> Vector2:
	if trail.is_empty():
		return Vector2.ZERO
	if is_instance_valid(trail[0]):
		return trail[0].position
	return Vector2.ZERO

func clear_trail() -> void:
	DebugLogger.log_info("Clearing trail...")
	for item in trail:
		item.queue_free()
	trail.clear()
	pickup_count = 0
	capture_count = 0
	DebugLogger.log_info("Trail cleared successfully!")

func _on_level_changed(new_level: int) -> void:
	level = new_level

func reset_trail_visuals(new_position: Vector2) -> void:
	DebugLogger.log_info("Resetting trail visuals...")
	move_history.clear()
	
	for i in range(pickup_count + 5):
		move_history.append(new_position)
	
	var local_pos = game_manager.to_local(new_position)
	for item in trail:
		if is_instance_valid(item):
			if item.has_meta("movement_tween"):
				var t = item.get_meta("movement_tween") as Tween
				if t and t.is_valid():
					t.kill()
			item.collision_active = false
			item.position = local_pos
	
	await get_tree().create_timer(1.0).timeout
	activate_trail_collisions()
	DebugLogger.log_info("Trail visuals reset successfully!")
