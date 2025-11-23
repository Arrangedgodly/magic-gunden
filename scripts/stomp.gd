extends Pickup

func _ready() -> void:
	super._ready()
	type = PickupType.Stomp

func apply_effect(powerup_manager: Node2D) -> void:
	powerup_manager.activate_stomp()
