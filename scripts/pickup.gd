extends Area2D
class_name Pickup

@onready var blue_potion: Sprite2D = $BluePotion
@onready var red_potion: Sprite2D = $RedPotion
@onready var green_potion: Sprite2D = $GreenPotion

enum PickupType {BLUE_POTION, RED_POTION, GREEN_POTION}

#RED = Stomp, GREEN = Magnet, Blue = Pierce

var type

func _ready() -> void:
	add_to_group("pickups")
	_set_pickup_type()
	_check_pickup_type()
	
	body_entered.connect(_on_body_entered)

func _set_pickup_type():
	var random_num = randi_range(0, 2)
	if random_num == 0:
		type = PickupType.BLUE_POTION
	elif random_num == 1:
		type = PickupType.RED_POTION
	elif random_num == 2:
		type = PickupType.GREEN_POTION

func _check_pickup_type():
	match type:
		PickupType.BLUE_POTION:
			blue_potion.visible = true
		PickupType.RED_POTION:
			red_potion.visible = true
		PickupType.GREEN_POTION:
			green_potion.visible = true

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		collect()

func collect():
	var game_manager = get_parent()
	if game_manager.has_method("activate_powerup"):
		game_manager.activate_powerup(type)
		
	queue_free()

func force_type(new_type):
	type = new_type
	
	blue_potion.visible = false
	red_potion.visible = false
	green_potion.visible = false
	
	_check_pickup_type()
