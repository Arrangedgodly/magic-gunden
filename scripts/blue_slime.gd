extends CharacterBody2D
class_name Slime

var player: CharacterBody2D
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
var is_moving: bool = false
var next_move_direction: Vector2 = Vector2.ZERO
var next_move_valid: bool = false

signal was_killed

func _ready():
	add_to_group("mobs")
	detection.collide_with_bodies = true
	detection.collide_with_areas = true
	var capture_points = get_tree().get_nodes_in_group("capture")
	for point in capture_points:
		var point_area = point.get_child(0)
		detection.add_exception(point_area)

func initialize(_player: CharacterBody2D) -> void:
	player = _player

func _physics_process(delta: float) -> void:
	if is_moving:
		return
		
	var collision = move_and_collide(velocity * delta)
	if collision:
		var collider = collision.get_collider()
		if collider is Player:
			if PowerupManager.stomp_active:
				kill()
			else:
				player.die()
		elif collider is Projectile:
			kill()

func move():
	if is_moving:
		return
		
	calculate_next_move()
	
	if next_move_valid:
		is_moving = true
		idle_direction(next_move_direction)
		await sprite.animation_looped
		
		var target_pos = position + next_move_direction * 32
		
		var tween = create_tween()
		tween.tween_property(self, "position", target_pos, 0.2)
		await tween.finished
		
		move_direction(next_move_direction)
		is_moving = false
	else:
		sprite.play("idle_down")

func calculate_next_move():
	randomize()
	next_move_valid = false
	var attempts = 0
	
	while not next_move_valid and attempts < 5:
		attempts += 1
		
		var random_num = randi_range(0, 3)
		var random_direction = directions[random_num]
		var random_angle = angles[random_num]
	
		detection.rotation_degrees = random_angle
		detection.force_raycast_update()
	
		if not detection.is_colliding():
			var target_pos = position + random_direction * 32
			
			if not is_position_occupied(target_pos):
				next_move_direction = random_direction
				next_move_valid = true

func is_position_occupied(pos: Vector2) -> bool:
	var slimes = get_tree().get_nodes_in_group("mobs")
	for slime in slimes:
		if slime != self and is_instance_valid(slime):
			if slime.position.distance_to(pos) < 16:
				return true
	
	if player and player.position.distance_to(pos) < 16:
		return true
	
	return false

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
	GameManager.increase_kill_count()
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
