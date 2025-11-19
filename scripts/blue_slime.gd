extends CharacterBody2D
class_name Slime

@onready var game_manager = get_parent()
@onready var player: CharacterBody2D = $"../../Player"
@onready var detection: RayCast2D = $Detection
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

@export var hurt_sound: AudioStream

const up = Vector2(0, -1)
const down = Vector2(0, 1)
const left = Vector2(-1, 0)
const right = Vector2(1, 0)
var directions = [down, left, up, right]
var angles = [0, 90, 180, 270]
var can_animation_change : bool

signal was_killed

func _ready():
	add_to_group("mobs")
	detection.collide_with_bodies = true
	var capture_points = get_tree().get_nodes_in_group("capture")
	for point in capture_points:
		var point_area = point.get_child(0)
		detection.add_exception(point_area)

func _physics_process(delta: float) -> void:
	var collision = move_and_collide(velocity * delta)
	if collision:
		var collider = collision.get_collider()
		if collider is Player:
			player.die()
		elif collider is Projectile:
			kill()

func move():
	randomize()
	var can_move = false
	
	while not can_move:
		var random_num = randi_range(0, 3)
		var random_direction = directions[random_num]
		var random_angle = angles[random_num]
	
		detection.rotation_degrees = random_angle
		detection.force_raycast_update()
	
		if not detection.is_colliding():
			can_move = true
			idle_direction(random_direction)
			await sprite.animation_looped
			position += random_direction * 32
			move_direction(random_direction)

func idle_direction(dir):
	if dir == right:
		sprite.flip_h = false
		sprite.play("idle_right")
	elif dir == left:
		sprite.flip_h = true
		sprite.play("idle_right")
	elif dir == up:
		sprite.play("idle_up")
	elif dir == down:
		sprite.play("idle_down")

func move_direction(dir):
	if dir == right:
		sprite.flip_h = false
		sprite.play("move_right")
		await sprite.animation_finished
		sprite.play("idle_right")
	elif dir == left:
		sprite.flip_h = true
		sprite.play("move_right")
		await sprite.animation_finished
		sprite.play("idle_right")
	elif dir == up:
		sprite.play("move_up")
		await sprite.animation_finished
		sprite.play("idle_up")
	elif dir == down:
		sprite.play("move_down")
		await sprite.animation_finished
		sprite.play("idle_down")

func kill():
	AudioManager.play_sound(hurt_sound)
	game_manager.increase_kill_count()
	sprite.play("death")
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", Color(10, 10, 10, 1), 1.0)
	was_killed.emit()
	queue_free()

func die():
	sprite.play("death")
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", Color(10, 10, 10, 1), 1.0)
	queue_free()
