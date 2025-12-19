extends Node2D
class_name PickupManager

signal gem_collected

@onready var player: CharacterBody2D = %Player
@onready var game_manager: Node2D = %GameManager
@onready var spawn: Node2D = %Spawn

var gem_scene = preload("res://scenes/gem.tscn")

var regen_gem: bool = true
var gem_pos: Vector2i
var level: int = 1
var tutorial_mode: bool = false

func _ready() -> void:
	if game_manager:
		game_manager.level_changed.connect(_on_level_changed)

func _process(_delta: float) -> void:
	if regen_gem:
		spawn_gem()

func reset_regen_gem() -> void:
	regen_gem = true
	gem_collected.emit()

func _on_level_changed(new_level: int) -> void:
	level = new_level

func spawn_gem() -> void:
	if not regen_gem:
		return
		
	regen_gem = false
	
	var pos
	if tutorial_mode:
		pos = spawn.random_pos_tutorial()
	else:
		pos = spawn.random_pos()
	var attempts = 0
	
	while not spawn.is_valid_spawn_position(pos) and attempts < 100:
		if tutorial_mode:
			pos = spawn.random_pos_tutorial()
		else:
			pos = spawn.random_pos()
		attempts += 1
	
	if attempts >= 100:
		return
	
	var gem_instance = gem_scene.instantiate()
	gem_instance.enable_pickup()
	gem_instance.position = pos
	gem_instance.position += Vector2.RIGHT * 16
	gem_instance.position += Vector2.DOWN * 16
	
	match level:
		1: gem_instance.play('blue')
		2: gem_instance.play('green')
		3: gem_instance.play('red')
	
	game_manager.add_child(gem_instance)

func enable_tutorial_mode() -> void:
	regen_gem = false
	tutorial_mode = true
