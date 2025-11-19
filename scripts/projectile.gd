extends AnimatedSprite2D
class_name Projectile

@onready var gpu_particles_2d: GPUParticles2D = $GPUParticles2D
@onready var character_body: CharacterBody2D = $CharacterBody2D
@export var projectile_sound: AudioStream
@export var hit_sound: AudioStream

var direction : Vector2
var speed = 1250
const up = Vector2(0, -1)
const down = Vector2(0, 1)
const left = Vector2(-1, 0)
const right = Vector2(1, 0)
const right_degrees = 0
const down_degrees = 90
const left_degrees = 180
const up_degrees = 270

func _ready() -> void:
	add_to_group("projectile")
	gpu_particles_2d.emitting = true
	AudioManager.play_sound(projectile_sound)
	character_body.on_collision.connect(_on_collision)
	
func set_direction(new_dir: Vector2):
	direction = new_dir
	if direction == right:
		rotation_degrees = right_degrees
	if direction == down:
		rotation_degrees = down_degrees
	if direction == left:
		rotation_degrees = left_degrees
	if direction == up:
		rotation_degrees = up_degrees
	
func _process(delta: float) -> void:
	position += direction * speed * delta
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 25, 1), 1.0)
	tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 1.0)

func _on_collision() -> void:
	AudioManager.play_sound(hit_sound)
	queue_free()
