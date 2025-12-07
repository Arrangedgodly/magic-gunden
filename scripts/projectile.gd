@icon("res://assets/icons/icon_bullet.png")
extends AnimatedSprite2D
class_name Projectile

@onready var gpu_particles_2d: GPUParticles2D = $GPUParticles2D
@onready var character_body: CharacterBody2D = $CharacterBody2D
@onready var on_screen_notifier: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D

@export var projectile_sound: AudioStream
@export var hit_sound: AudioStream

var direction : Vector2
var speed = 1250
var is_piercing: bool = false
var can_ricochet: bool = false
var max_bounces: int = 0
var current_bounces: int = 0
var ignored_bodies: Array = []

signal shot_missed

func _ready() -> void:
	add_to_group("projectile")
	top_level = true
	global_position = get_parent().global_position
	
	if get_parent() is CharacterBody2D:
		character_body.add_collision_exception_with(get_parent())
		
	gpu_particles_2d.emitting = true
	AudioManager.play_sound(projectile_sound)
	
	character_body.on_collision.connect(_on_collision)
	on_screen_notifier.screen_exited.connect(_on_screen_notifier_screen_exited)
	
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
			
		if can_ricochet and current_bounces < max_bounces and collider.is_in_group("mobs"):
			AudioManager.play_sound(hit_sound)
			attempt_ricochet(collider)
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

func attempt_ricochet(hit_enemy: Node2D) -> void:
	current_bounces += 1
	ignored_bodies.append(hit_enemy)
	
	var nearest_enemy = find_nearest_enemy(global_position)
	
	if nearest_enemy:
		var new_dir = (nearest_enemy.global_position - global_position).normalized()
		set_direction(new_dir)
		
		position += new_dir * 20 
	else:
		_on_collision()

func find_nearest_enemy(current_pos: Vector2) -> Node2D:
	var enemies = get_tree().get_nodes_in_group("mobs")
	var nearest: Node2D = null
	var min_dist: float = INF 
	
	for enemy in enemies:
		if enemy in ignored_bodies or not is_instance_valid(enemy):
			continue
			
		var dist = current_pos.distance_squared_to(enemy.global_position)
		if dist < min_dist:
			min_dist = dist
			nearest = enemy
			
	return nearest

func _on_screen_notifier_screen_exited() -> void:
	shot_missed.emit()
