extends Pickup
class_name GrenadePickup

func _ready() -> void:
	super._ready()
	type = PickupType.Grenade

func _process(_delta: float) -> void:
	if is_active:
		var projectiles = get_tree().get_nodes_in_group("projectile")
		for projectile in projectiles:
			if not projectile.is_explosive:
				projectile.is_explosive = true

func activate(manager: PowerupManager) -> void:
	super.activate(manager)
	
	manager.register_grenade_powerup(self)
	manager.powerup_activated.emit("Grenade")

func get_powerup_name() -> String:
	return "Grenade"
