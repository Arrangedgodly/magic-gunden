extends Area2D

signal player_fell_off_map

func _ready() -> void:
	add_to_group("killzone")

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		player_fell_off_map.emit()
		
		body.die()
