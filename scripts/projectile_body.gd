extends CharacterBody2D

signal on_collision

func _physics_process(delta: float) -> void:
	var collision = move_and_collide(velocity * delta)
	if collision:
		var collider = collision.get_collider()
		if collider is Slime:
			on_collision.emit()
			collider.kill()
