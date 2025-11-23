extends Area2D
class_name Pickup

@export var icon: Texture

enum PickupType {Stomp, Magnet, Ricochet, Pierce}

var type: PickupType

func _ready() -> void:
	add_to_group("pickups")
	
	var collision_shape = CollisionShape2D.new()
	collision_shape.shape = CircleShape2D.new()
	collision_shape.shape.radius = 16
	add_child(collision_shape)
	
	var sprite = Sprite2D.new()
	sprite.texture = icon
	add_child(sprite)
	
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		collect()

func collect():
	var game_manager = get_parent()
	apply_effect(game_manager)
		
	queue_free()

func apply_effect(game_manager: Node2D) -> void:
	print("Pickup collected but no effect defined")
