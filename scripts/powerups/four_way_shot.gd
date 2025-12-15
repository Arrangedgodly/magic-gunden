extends Pickup
class_name FourWayShotPickup

var player: Player

func _ready() -> void:
	super._ready()
	type = PickupType.FourWayShot
	
	player = get_node_or_null("/root/MagicGarden/World/GameplayArea/Player")

func activate(manager: PowerupManager) -> void:
	super.activate(manager)
	
	player.four_way_shot_active = true
	
	manager.register_four_way_shot_pickup(self)
	manager.powerup_activated.emit("FourWayShot")

func _on_timeout() -> void:
	player.four_way_shot_active = false
	
	super._on_timeout()
