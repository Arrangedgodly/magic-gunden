extends Area2D
class_name Explosion

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var explosion_sound: AudioStream = preload("res://assets/sounds/sfx/explosion_large_03.wav")

func _ready() -> void:
	AudioManager.play_sound(explosion_sound)
	sprite.animation_finished.connect(_on_sprite_animation_finished)
	body_entered.connect(_on_body_entered)

func _on_sprite_animation_finished() -> void:
	queue_free()

func _on_body_entered(body) -> void:
	var enemies = get_tree().get_nodes_in_group("mobs")
	for enemy in enemies:
		if body == enemy:
			enemy.kill()
