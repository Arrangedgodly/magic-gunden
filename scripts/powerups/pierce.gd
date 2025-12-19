extends Powerup
class_name PiercePowerup

func _ready() -> void:
	super._ready()
	type = PowerupType.Pierce

func activate(manager: PowerupManager) -> void:
	super.activate(manager)
	
	manager.register_pierce_powerup(self)
	manager.powerup_activated.emit("Pierce")

func get_powerup_name() -> String:
	return "Pierce"

func should_projectile_pierce() -> bool:
	return is_active
