extends Powerup
class_name StompPowerup

func _ready() -> void:
	super._ready()
	type = PowerupType.Stomp

func activate(manager: PowerupManager) -> void:
	super.activate(manager)
	
	manager.register_stomp_powerup(self)
	manager.powerup_activated.emit("Stomp")

func get_powerup_name() -> String:
	return "Stomp"
	
func should_kill_enemy_on_collision() -> bool:
	return is_active
