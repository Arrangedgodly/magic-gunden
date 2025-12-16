extends Area2D

@onready var laser: AnimatedSprite2D = %Laser

var damage_delayed: bool = false

func _ready() -> void:
	laser.play("fire")
	
	await laser.animation_finished
	
	laser.play("middle")
	
	await laser.animation_looped
	
	laser.flip_h = true
	laser.play("end")
	
	await laser.animation_finished
	
	queue_free()
	
	# 2. Audio
	# AudioManager.play_sound(laser_sound)


func _physics_process(_delta: float) -> void:
	if not damage_delayed:
		_deal_damage()
		damage_delayed = true

func _deal_damage() -> void:
	var bodies = get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("mobs") and body.has_method("kill"):
			body.kill()

func setup(pos: Vector2, direction: Vector2) -> void:
	position = pos
	rotation = direction.angle()
