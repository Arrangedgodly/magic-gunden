extends AnimatedSprite2D
@onready var gpu_particles_2d: GPUParticles2D = $GPUParticles2D
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

func _on_area_2d_area_entered(area: Area2D) -> void:
	var slimes = get_tree().get_nodes_in_group("slimearea")
	for slime in slimes:
		if area == slime:
			AudioManager.play_sound(hit_sound)
			queue_free()
