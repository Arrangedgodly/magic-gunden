extends CharacterBody2D
class_name Slime

@onready var game_manager = get_parent()
@onready var player: CharacterBody2D = $"../../Player"
@onready var detection: RayCast2D = $Detection
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var fire_fx: AnimatedSprite2D = $FireFx
@onready var ice_fx: AnimatedSprite2D = $IceFx
@onready var poison_fx: AnimatedSprite2D = $PoisonFx
@onready var powerup_manager: PowerupManager

@export var hurt_sound: AudioStream

const up = Vector2(0, -1)
const down = Vector2(0, 1)
const left = Vector2(-1, 0)
const right = Vector2(1, 0)

var directions = [down, left, up, right]
var angles = [0, 90, 180, 270]
var can_animation_change : bool
var current_move_direction: Vector2 = Vector2.ZERO

signal was_killed

func _ready():
	powerup_manager = get_node("/root/MagicGarden/PowerupManager")
	hide_fire()
	hide_ice()
	hide_poison()
	
	add_to_group("mobs")
	detection.collide_with_bodies = true
	detection.collide_with_areas = true
	var capture_points = get_tree().get_nodes_in_group("capture")
	for point in capture_points:
		var point_area = point.get_child(0)
		detection.add_exception(point_area)

func _physics_process(delta: float) -> void:
	var collision = move_and_collide(velocity * delta)
	if collision:
		var collider = collision.get_collider()
		if collider is Player:
			if powerup_manager.stomp_active:
				kill()
			else:
				player.die()
		elif collider is Projectile:
			kill()

func calculate_move(intended_positions: Dictionary) -> Dictionary:
	randomize()
	var attempts = 0
	var max_attempts = 5
	
	var shuffled_directions = directions.duplicate()
	shuffled_directions.shuffle()
	
	while attempts < max_attempts:
		attempts += 1
		
		var random_index = attempts - 1
		if random_index >= shuffled_directions.size():
			break
			
		var random_direction = shuffled_directions[random_index]
		var direction_index = directions.find(random_direction)
		var random_angle = angles[direction_index]
		
		var target_position = position + (random_direction * 32)
		
		detection.rotation_degrees = random_angle
		detection.force_raycast_update()
		
		if detection.is_colliding():
			continue
		
		if is_trail_at_position(target_position):
			continue
		
		if intended_positions.has(target_position):
			continue
		
		if is_enemy_at_position(target_position):
			continue
		
		return {
			"can_move": true,
			"direction": random_direction,
			"target_position": target_position
		}
	
	return {
		"can_move": false,
		"direction": Vector2.ZERO,
		"target_position": position
	}

func start_idle_animation(direction: Vector2) -> void:
	current_move_direction = direction
	idle_direction(direction)

func execute_movement(target_pos: Vector2) -> void:
	var tween = create_tween()
	tween.tween_property(self, "position", target_pos, 0.2).set_trans(Tween.TRANS_SINE)
	
	move_direction(current_move_direction)

func is_trail_at_position(target_pos: Vector2) -> bool:
	var trail_pieces = get_tree().get_nodes_in_group("equipped")
	for piece in trail_pieces:
		if is_instance_valid(piece):
			var distance = target_pos.distance_to(piece.global_position)
			if distance < 16:
				return true
	return false

func is_enemy_at_position(target_pos: Vector2) -> bool:
	var enemies = get_tree().get_nodes_in_group("mobs")
	for enemy in enemies:
		if enemy == self:
			continue
		if is_instance_valid(enemy):
			var distance = target_pos.distance_to(enemy.position)
			if distance < 16:
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

func show_fire() -> void:
	fire_fx.show()

func hide_fire() -> void:
	fire_fx.hide()

func show_ice() -> void:
	ice_fx.show()

func hide_ice() -> void:
	ice_fx.hide()

func show_poison() -> void:
	poison_fx.show()

func hide_poison() -> void:
	poison_fx.hide()
