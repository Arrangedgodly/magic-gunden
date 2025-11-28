extends Node2D
class_name PickupManager

signal yoyo_collected
signal powerup_spawned(position: Vector2)

@onready var player: CharacterBody2D = %Player
@onready var game_manager: Node2D = %GameManager

var yoyo_scene = preload("res://scenes/yoyo.tscn")
var stomp_scene = preload("res://scenes/powerups/stomp.tscn")
var magnet_scene = preload("res://scenes/powerups/magnet.tscn")
var pierce_scene = preload("res://scenes/powerups/pierce.tscn")
var ricochet_scene = preload("res://scenes/powerups/ricochet.tscn")
var poison_scene = preload("res://scenes/powerups/poison.tscn")
var auto_aim_scene = preload("res://scenes/powerups/auto_aim.tscn")
var flames_scene = preload("res://scenes/powerups/flames.tscn")
var free_ammo_scene = preload("res://scenes/powerups/free_ammo.tscn")
var ice_scene = preload("res://scenes/powerups/ice.tscn")
var jump_scene = preload("res://scenes/powerups/jump.tscn")
var time_pause_scene = preload("res://scenes/powerups/time_pause.tscn")
var regen_yoyo: bool = true
var yoyo_pos: Vector2i
var level: int = 1
var available_pickups: Array[PackedScene]

const TILES = 12
const TILE_SIZE = 32

func _ready() -> void:
	if game_manager:
		game_manager.level_changed.connect(_on_level_changed)
	
	available_pickups = [
	magnet_scene, 
	pierce_scene, 
	ricochet_scene, 
	stomp_scene,
	poison_scene,
	auto_aim_scene,
	flames_scene,
	free_ammo_scene,
	ice_scene,
	jump_scene,
	time_pause_scene
]

func _process(_delta: float) -> void:
	if regen_yoyo:
		place_yoyo()

func place_yoyo() -> void:
	if not regen_yoyo:
		return
		
	regen_yoyo = false
	yoyo_pos = random_pos()
	var attempts = 0
	
	while not is_valid_spawn_position(yoyo_pos) and attempts < 100:
		yoyo_pos = random_pos()
		attempts += 1
	
	if attempts >= 100:
		regen_yoyo = true
		return
		
	var yoyo_instance = yoyo_scene.instantiate()
	yoyo_instance.enable_pickup()
	yoyo_instance.position = yoyo_pos
	yoyo_instance.position += Vector2.RIGHT * 16
	yoyo_instance.position += Vector2.DOWN * 16
	
	match level:
		1: yoyo_instance.play('blue')
		2: yoyo_instance.play('green')
		3: yoyo_instance.play('red')
	
	game_manager.add_child(yoyo_instance)

func reset_regen_yoyo() -> void:
	regen_yoyo = true
	yoyo_collected.emit()

func spawn_pickup() -> void:
	var pickup_pos = random_pos()
	var attempts = 0
	
	while not is_valid_spawn_position(pickup_pos) and attempts < 100:
		pickup_pos = random_pos()
		attempts += 1
	
	if attempts >= 100:
		return
	
	var random_scene = available_pickups.pick_random()
	var pickup = random_scene.instantiate()
	pickup.position = pickup_pos
	pickup.position += Vector2(16, 16)
	game_manager.add_child(pickup)
	powerup_spawned.emit(pickup_pos)

func force_spawn_pickup(index: int) -> void:
	var pos = random_pos()
	var scene = available_pickups[index]
	var pickup = scene.instantiate()
	
	pickup.position = pos
	pickup.position += Vector2(16, 16)
	game_manager.add_child(pickup)
	powerup_spawned.emit()
	
func random_pos() -> Vector2i:
	randomize()
	var x = (randi_range(0, TILES - 1) * TILE_SIZE)
	var y = (randi_range(0, TILES - 1) * TILE_SIZE)
	return Vector2i(x, y)

func is_valid_spawn_position(pos: Vector2) -> bool:
	if not player:
		return false
		
	if player.position == pos:
		return false
	
	for child in game_manager.get_children():
		if child is AnimatedSprite2D and child.position == pos:
			return false
	
	if game_manager.has_node("TrailManager"):
		var trail_manager = game_manager.get_node("TrailManager")
		for yoyo_instance in trail_manager.trail:
			if is_instance_valid(yoyo_instance) and yoyo_instance.position == pos:
				return false
	
	return true

func _on_level_changed(new_level: int) -> void:
	level = new_level

func force_spawn_yoyo() -> void:
	var pos = random_pos()
	var attempts = 0
	
	while not is_valid_spawn_position(pos) and attempts < 100:
		pos = random_pos()
		attempts += 1
	
	if attempts >= 100:
		return
	
	var yoyo_instance = yoyo_scene.instantiate()
	yoyo_instance.enable_pickup()
	yoyo_instance.position = pos
	yoyo_instance.position += Vector2.RIGHT * 16
	yoyo_instance.position += Vector2.DOWN * 16
	
	match level:
		1: yoyo_instance.play('blue')
		2: yoyo_instance.play('green')
		3: yoyo_instance.play('red')
	
	game_manager.add_child(yoyo_instance)
