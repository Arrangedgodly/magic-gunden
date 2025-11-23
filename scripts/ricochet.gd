extends Pickup

func _ready() -> void:
	super._ready()
	type = PickupType.Ricochet

func apply_effect(game_manager: Node2D) -> void:
	var player = game_manager.player
	if player:
		player.activate_ricochet()
		game_manager.ricochet_timer.start()
