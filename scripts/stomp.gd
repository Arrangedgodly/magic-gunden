extends Pickup

func _ready() -> void:
	super._ready()
	type = PickupType.Stomp

func apply_effect(game_manager: Node2D) -> void:
	game_manager.stomp_active = true
	game_manager.stomp_timer.start()
	await game_manager.stomp_timer.timeout
	game_manager.stomp_active = false
