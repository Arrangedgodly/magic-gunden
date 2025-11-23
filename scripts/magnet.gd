extends Pickup

func _ready() -> void:
	super._ready()
	type = PickupType.Magnet

func apply_effect(game_manager: Node2D) -> void:
	game_manager.magnet_active = true
	game_manager.magnet_timer.start()
	await game_manager.magnet_timer.timeout
	game_manager.magnet_active = false
