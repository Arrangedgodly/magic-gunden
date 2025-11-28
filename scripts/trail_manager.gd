extends Node2D
class_name TrailManager

signal trail_item_converted_to_ammo(streak: int, position: Vector2)
signal trail_item_converted_to_enemy(position: Vector2)
signal trail_released(items_captured: int)

@onready var player: CharacterBody2D = %Player
@onready var game_manager: Node2D = %GameManager

var trail: Array = []
var move_history: Array = []
var pickup_count: int = 0
var capture_count: int = 0
var yoyo_scene_path: String = "res://scenes/yoyo.tscn"
var blue_slime_scene_path: String = "res://scenes/blue_slime.tscn"

const ANIMATION_SPEED = 5
var level: int = 1

func _ready() -> void:
	if game_manager:
		game_manager.level_changed.connect(_on_level_changed)

func update_move_history(current_position: Vector2) -> void:
	if len(move_history) > pickup_count:
		move_history.pop_front()
	move_history.append(current_position)
	
	activate_trail_collisions()

func activate_trail_collisions() -> void:
	for i in range(trail.size()):
		if i < trail.size() - 1:
			var piece = trail[i]
			if is_instance_valid(piece) and piece.has_method("activate_collision"):
				piece.activate_collision()

func create_trail_segment() -> void:
	if move_history.is_empty():
		return
	
	var yoyo_scene = load(yoyo_scene_path)
	var yoyo_instance = yoyo_scene.instantiate()
	var last_position = move_history[len(move_history) - 1]
	var local_position = game_manager.to_local(last_position)
	
	yoyo_instance.position = local_position
	yoyo_instance.negate_pickup()
	
	match level:
		1: yoyo_instance.play("blue")
		2: yoyo_instance.play("green")
		3: yoyo_instance.play("red")
	
	game_manager.call_deferred("add_child", yoyo_instance)
	yoyo_instance.add_to_group("equipped")
	trail.append(yoyo_instance)
	pickup_count += 1

func move_trail() -> void:
	if trail.is_empty():
		return
		
	for i in range(len(trail)):
		if i + 1 < len(move_history):
			var target_position = move_history[-(i + 1)]
			var local_position = game_manager.to_local(target_position)
			var tween = game_manager.create_tween()
			tween.tween_property(trail[i], "position", local_position, 1.0/ANIMATION_SPEED).set_trans(Tween.TRANS_SINE)

func release_trail() -> void:
	if trail.is_empty():
		trail_released.emit(0)
		return
	
	capture_count = 0
	
	var items_to_convert = []
	for item in trail:
		var item_data = {
			"node": item,
			"position": item.position,
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
			trail_item_converted_to_ammo.emit(current_streak, item_data.position)
		else:
			var blue_slime_scene = load(blue_slime_scene_path)
			var enemy_instance = blue_slime_scene.instantiate()
			enemy_instance.position = item_data.position
			game_manager.add_child(enemy_instance)
			
			if game_manager.has_method("increase_slimes_killed"):
				enemy_instance.was_killed.connect(game_manager.increase_slimes_killed)
			
			trail_item_converted_to_enemy.emit(item_data.position)
		
		if is_instance_valid(item_data.node):
			item_data.node.queue_free()
	
	trail_released.emit(items_captured)

func is_on_capture_point(item: Node2D) -> bool:
	var capture_points = game_manager.get_tree().get_nodes_in_group("capture")
	
	for point in capture_points:
		var detected_body = point.check_detected_body()
		if detected_body:
			if detected_body.position == item.position:
				return true
	
	return false

func convert_to_enemy(pickup: Node2D) -> void:
	await pickup.flash(Color(255, 0, 0, 255))
	
	var blue_slime_scene = load(blue_slime_scene_path)
	var enemy_instance = blue_slime_scene.instantiate()
	enemy_instance.position = pickup.position
	game_manager.add_child(enemy_instance)
	
	if game_manager.has_method("increase_slimes_killed"):
		enemy_instance.was_killed.connect(game_manager.increase_slimes_killed)
	
	pickup.queue_free()
	trail_item_converted_to_enemy.emit(pickup.position)

func convert_to_ammo(pickup: Node2D, streak: int) -> void:
	await pickup.flash(Color(0, 255, 0, 255))
	
	pickup.queue_free()
	trail_item_converted_to_ammo.emit(streak, pickup.position)

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
	for item in trail:
		item.queue_free()
	trail.clear()
	pickup_count = 0
	capture_count = 0

func _on_level_changed(new_level: int) -> void:
	level = new_level
