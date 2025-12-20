extends Node2D
class_name CapturePointManager

signal capture_points_spawned(count: int)
signal capture_points_cleared
signal capture_animation_played

@onready var game_manager: Node2D = %GameManager
@onready var capture_point_timer: Timer = $CapturePointTimer
@onready var capture_point_animation: Timer = $CapturePointAnimation

@export var capture_sfx: AudioStream

var capture_point_scene = preload("res://scenes/capture_point.tscn")

var level: int = 1
var capture_pattern_bar: bool = false
var bars_vertical: bool = true
var tutorial_mode: bool = false
var tutorial_pattern: bool = false

const TILES = 12
const TILE_SIZE = 32

func _ready() -> void:
	capture_point_timer.timeout.connect(_on_capture_point_timer_timeout)
	capture_point_animation.timeout.connect(_on_capture_point_animation_timeout)
	
	if game_manager:
		game_manager.level_changed.connect(_on_level_changed)

func start_capture_systems() -> void:
	capture_point_timer.start()
	capture_point_animation.start()

func stop_capture_systems() -> void:
	capture_point_timer.stop()
	capture_point_animation.stop()

func reset_capture_timers() -> void:
	capture_point_timer.stop()
	capture_point_timer.emit_signal("timeout")
	capture_point_animation.stop()

func spawn_tutorial_pattern(starting_pos: Vector2i) -> int:
	var count = 0
	
	for i in range(3):
		var capture_point_instance = capture_point_scene.instantiate()
		capture_point_instance.position = starting_pos
		capture_point_instance.position += Vector2.DOWN * 16
		capture_point_instance.position += Vector2.RIGHT * 16
		
		capture_point_instance.position.x += i * TILE_SIZE
		
		set_capture_point_color(capture_point_instance)
		game_manager.add_child(capture_point_instance)
		count += 1
	
	return count

func spawn_capture_points(starting_pos: Vector2i) -> void:
	var points_spawned = 0
	
	if tutorial_pattern:
		points_spawned = spawn_tutorial_pattern(starting_pos)
	elif capture_pattern_bar:
		points_spawned = spawn_bar_pattern(starting_pos)
	else:
		points_spawned = spawn_cross_pattern(starting_pos)
	
	capture_points_spawned.emit(points_spawned)
	capture_point_timer.start()
	capture_point_animation.start()

func spawn_bar_pattern(starting_pos: Vector2i) -> int:
	capture_pattern_bar = false
	var count = 0
	
	for i in range(12):
		var capture_point_instance = capture_point_scene.instantiate()
		capture_point_instance.position = starting_pos
		capture_point_instance.position += Vector2.DOWN * 16
		capture_point_instance.position += Vector2.RIGHT * 16
		
		if not bars_vertical:
			capture_point_instance.position.x += i * TILE_SIZE
		else:
			capture_point_instance.position.y += i * TILE_SIZE
		
		set_capture_point_color(capture_point_instance)
		game_manager.add_child(capture_point_instance)
		count += 1
	
	return count

func spawn_cross_pattern(starting_pos: Vector2i) -> int:
	capture_pattern_bar = true
	var count = 0
	
	for i in range(16):
		var capture_point_instance = capture_point_scene.instantiate()
		capture_point_instance.position = starting_pos
		capture_point_instance.position += Vector2.DOWN * 16
		capture_point_instance.position += Vector2.RIGHT * 16
		
		@warning_ignore("integer_division")
		var row = i / 4
		var col = i % 4
		
		capture_point_instance.position.x += col * TILE_SIZE
		capture_point_instance.position.y += row * TILE_SIZE
		
		if row == 0 and (col == 1 or col == 2):
			set_capture_point_color(capture_point_instance)
			game_manager.add_child(capture_point_instance)
			count += 1
		elif row == 1 or row == 2:
			set_capture_point_color(capture_point_instance)
			game_manager.add_child(capture_point_instance)
			count += 1
		elif row == 3 and (col == 1 or col == 2):
			set_capture_point_color(capture_point_instance)
			game_manager.add_child(capture_point_instance)
			count += 1
		else:
			capture_point_instance.queue_free()
	
	return count

func set_capture_point_color(capture_point: AnimatedSprite2D) -> void:
	match level:
		1: capture_point.play("blue")
		2: capture_point.play("green")
		3: capture_point.play("red")

func find_capture_spawn_point() -> Vector2i:
	var x = 0
	var y = 0
	randomize()
	
	if capture_pattern_bar:
		if bars_vertical:
			y = (randi_range(0, TILES - 1) * TILE_SIZE)
			bars_vertical = false
		else:
			x = (randi_range(0, TILES - 1) * TILE_SIZE)
			bars_vertical = true
	else:
		y = (randi_range(1, TILES - 5) * TILE_SIZE)
		x = (randi_range(1, TILES - 5) * TILE_SIZE)
	
	return Vector2i(x, y)

func clear_capture_points() -> void:
	var capture_points = get_tree().get_nodes_in_group("capture")
	for point in capture_points:
		point.queue_free()
	capture_points_cleared.emit()

func flash_capture_points() -> void:
	capture_point_animation.stop()
	var capture_points = get_tree().get_nodes_in_group("capture")
	AudioManager.play_sound(capture_sfx)
	for point in capture_points:
		point.flash()
	await get_tree().create_timer(1.5).timeout
	AudioManager.play_sound(capture_sfx)
	await get_tree().create_timer(1.5).timeout

func get_capture_point_count() -> int:
	return get_tree().get_nodes_in_group("capture").size()

func initialize_first_spawn() -> void:
	var spawn_point = find_capture_spawn_point()
	spawn_capture_points(spawn_point)

func _on_capture_point_timer_timeout() -> void:
	if tutorial_mode:
		capture_point_timer.stop()
		return
		
	cycle_capture_points()
	
func cycle_capture_points() -> void:
	clear_capture_points()
	
	await get_tree().process_frame
	
	var spawn_point = find_capture_spawn_point()
	spawn_capture_points(spawn_point)

func _on_capture_point_animation_timeout() -> void:
	if not tutorial_mode:
		await flash_capture_points()
	
		capture_animation_played.emit()

func _on_level_changed(new_level: int) -> void:
	level = new_level

func enable_tutorial_mode() -> void:
	tutorial_mode = true
	stop_capture_systems()
	cycle_capture_points()

func disable_tutorial_mode() -> void:
	tutorial_mode = false
