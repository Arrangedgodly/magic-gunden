extends StaticBody2D

@onready var blue_potion: Sprite2D = $BluePotion
@onready var red_potion: Sprite2D = $RedPotion
@onready var green_potion: Sprite2D = $GreenPotion

enum PickupType {BLUE_POTION, RED_POTION, GREEN_POTION}

var type

func _ready() -> void:
	_set_pickup_type()
	_check_pickup_type()

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
