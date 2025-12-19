extends Powerup
class_name FreeAmmoPowerup

var ammo_generation_interval: float = 1.0
var time_since_last_ammo: float = 0.0
var game_manager: Node2D
var ammo_manager: AmmoManager

func _ready() -> void:
	super._ready()
	type = PowerupType.FreeAmmo

func activate(manager: PowerupManager) -> void:
	super.activate(manager)
	
	game_manager = manager.game_manager
	ammo_manager = get_node("/root/MagicGarden/Systems/AmmoManager")
	time_since_last_ammo = 0.0
	
	manager.register_free_ammo_powerup(self)
	manager.powerup_activated.emit("FreeAmmo")

func get_powerup_name() -> String:
	return "FreeAmmo"

func process_effect(delta: float) -> void:
	if not is_active or not game_manager:
		return
	
	time_since_last_ammo += delta
	
	if time_since_last_ammo >= ammo_generation_interval:
		time_since_last_ammo = 0.0
		ammo_manager.increase_ammo_count()

func _on_timeout() -> void:
	time_since_last_ammo = 0.0
	super._on_timeout()
