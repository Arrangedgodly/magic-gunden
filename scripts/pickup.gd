@icon("res://assets/icons/icon_potion.png")
extends Area2D
class_name Pickup

@export var icon: Texture

enum PickupType {Stomp, Magnet, Ricochet, Pierce, Poison, AutoAim, Health, Flames, FreeAmmo, Ice, Jump, TimePause, Grenade, FourWayShot, Laser}

var duration: float = 10.0
var type: PickupType
var powerup_manager: PowerupManager
var is_active: bool = false
var timer: Timer
var sprite: Sprite2D
var collision_node: CollisionShape2D

func _ready() -> void:
	add_to_group("pickups")
	
	z_index = 2
	
	collision_node = CollisionShape2D.new()
	var collision_shape = CircleShape2D.new()
	collision_shape.radius = 16
	collision_node.shape = collision_shape
	add_child(collision_node)
	
	sprite = Sprite2D.new()
	sprite.texture = icon
	add_child(sprite)
	
	body_entered.connect(_on_body_entered)
	
	powerup_manager = get_node("/root/MagicGarden/Systems/PowerupManager")

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		collect()

func collect():
	if powerup_manager:
		sprite.visible = false
		collision_node.set_deferred("disabled", true)
		call_deferred("_transfer_and_activate")
		
	else:
		queue_free()

func _transfer_and_activate() -> void:
	if get_parent():
		get_parent().remove_child(self)
	
	powerup_manager.add_child(self)
	activate(powerup_manager)

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
	
	queue_free()

func get_timer() -> Timer:
	return timer
