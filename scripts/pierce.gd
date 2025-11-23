extends Pickup

func _ready() -> void:
	super._ready()
	type = PickupType.Pierce

func apply_effect(game_manager: Node2D) -> void:
	game_manager.piercing_active = true
	game_manager.pierce_timer.start()
	await game_manager.pierce_timer.timeout
	game_manager.piercing_active = false
