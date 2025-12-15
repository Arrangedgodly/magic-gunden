extends Pickup
class_name LaserPickup

func _ready() -> void:
	super._ready()
	type = PickupType.Laser

func activate(manager: PowerupManager) -> void:
	super.activate(manager)
	
	manager.register_laser_powerup(self)
	manager.powerup_activated.emit("Laser")

func get_powerup_name() -> String:
	return "Laser"
