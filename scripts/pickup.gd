extends Area2D
class_name Pickup

@export var icon: Texture

@onready var sprite: Sprite2D = $Sprite2D

enum PickupType {Stomp, Magnet, Ricochet, Pierce, Poison, AutoAim, Health, Flames, FreeAmmo, Ice, Jump}

var duration: float = 10.0
var type: PickupType
var powerup_manager: PowerupManager
var is_active: bool = false
var timer: Timer

func _ready() -> void:
	add_to_group("pickups")
	
	sprite.texture = icon
	
	body_entered.connect(_on_body_entered)
	
	powerup_manager = get_node("/root/MagicGarden/PowerupManager")

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		collect()

func collect():
	if powerup_manager:
		activate(powerup_manager)
		
	queue_free()

func activate(manager: PowerupManager) -> void:
	powerup_manager = manager
	
	timer = Timer.new()
	timer.wait_time = duration
	timer.one_shot = true
	timer.timeout.connect(_on_timeout)
	manager.add_child(timer)
	
	is_active = true
	timer.start()

func get_powerup_name() -> String:
	return "Powerup"

func get_duration() -> float:
	return duration

func _on_timeout() -> void:
	is_active = false
	if timer:
		timer.queue_free()

func get_timer() -> Timer:
	return timer
