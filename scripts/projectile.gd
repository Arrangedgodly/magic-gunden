extends AnimatedSprite2D
class_name Projectile

@onready var gpu_particles_2d: GPUParticles2D = $GPUParticles2D
@onready var character_body: CharacterBody2D = $CharacterBody2D
@export var projectile_sound: AudioStream
@export var hit_sound: AudioStream

var direction : Vector2
var speed = 1250
var is_piercing: bool = false

func _ready() -> void:
	add_to_group("projectile")
	top_level = true
	global_position = get_parent().global_position
	
	if get_parent() is CharacterBody2D:
		character_body.add_collision_exception_with(get_parent())
		
	gpu_particles_2d.emitting = true
	AudioManager.play_sound(projectile_sound)
	character_body.on_collision.connect(_on_collision)
	
func set_direction(new_dir: Vector2):
	direction = new_dir
	rotation = direction.angle()
	
func _process(delta: float) -> void:
	var motion = direction * speed * delta
	var collision = character_body.move_and_collide(motion, true)
	
	if collision:
		var collider = collision.get_collider()
		if collider.has_method("kill"):
			collider.kill()
			_on_collision()
		elif collider.is_in_group("mobs"):
			collider.kill()
			_on_collision()
		else:
			_on_collision()
	else:
		position += motion
	
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 25, 1), 1.0)
	tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 1.0)

func _on_collision() -> void:
	AudioManager.play_sound(hit_sound)
	
	if not is_piercing:
		queue_free()
