@icon("res://assets/icons/icon_skull.png")
extends CharacterBody2D
class_name Slime

@onready var game_manager = get_parent()
@onready var player: CharacterBody2D
@onready var detection: RayCast2D = $Detection
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var fire_fx: AnimatedSprite2D = $FireFx
@onready var ice_fx: AnimatedSprite2D = $IceFx
@onready var poison_fx: AnimatedSprite2D = $PoisonFx
@onready var powerup_manager: PowerupManager
@onready var score_manager: ScoreManager

var hurt_sound: AudioStream = preload("res://assets/sounds/sfx/hurt2.ogg")
var fire_sound: AudioStream = preload("res://assets/sounds/sfx/fire_burning_flames_crackle_loop_01.wav")
var ice_sound: AudioStream = preload("res://assets/sounds/sfx/ice_spell_freeze_ground_03.wav")

const up = Vector2(0, -1)
const down = Vector2(0, 1)
const left = Vector2(-1, 0)
const right = Vector2(1, 0)

var directions = [down, left, up, right]
var angles = [0, 90, 180, 270]
var can_animation_change : bool
var current_move_direction: Vector2 = Vector2.ZERO

signal was_killed
signal player_hit_by_enemy

func _ready():
	powerup_manager = get_node("/root/MagicGarden/Systems/PowerupManager")
	score_manager = get_node("/root/MagicGarden/Systems/ScoreManager")
	player = get_node("/root/MagicGarden/World/GameplayArea/Player")
	hide_fire()
	hide_ice()
	hide_poison()
	
	add_to_group("mobs")
	add_to_group("laser_exception")
	
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
			if powerup_manager and powerup_manager.is_jump_active():
				var can_jump = powerup_manager.check_jump_enemy_collision(self)
				if can_jump:
					return
			
			if powerup_manager and powerup_manager.is_stomp_active():
				kill()
			else:
				player_hit_by_enemy.emit()
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
		
		var raw_target = position + (random_direction * 32)
		var grid_x = floor(raw_target.x / 32)
		var grid_y = floor(raw_target.y / 32)
		var target_position = Vector2(grid_x * 32 + 16, grid_y * 32 + 16)
		
		detection.rotation_degrees = random_angle
		detection.force_raycast_update()
		
		if detection.is_colliding():
			var collider = detection.get_collider()

			var is_capture_point = false
			if collider.get_parent() and collider.get_parent().is_in_group("capture"):
				is_capture_point = true

			if not is_capture_point:
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
	var movement_duration = 0.2
	if has_meta("is_slowed"):
		movement_duration = 1.0
	
	var movement_tween = create_tween()
	movement_tween.tween_property(self, "position", target_pos, movement_duration).set_trans(Tween.TRANS_SINE)
	
	move_direction(current_move_direction)

func is_trail_at_position(target_pos: Vector2) -> bool:
	var trail_pieces = get_tree().get_nodes_in_group("equipped")
	for piece in trail_pieces:
		if is_instance_valid(piece):
			var distance = target_pos.distance_to(piece.global_position)
			if distance < 28:
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
	score_manager.increase_kill_count()
	sprite.play("death")
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", Color(10, 10, 10, 1), 1.0)
	was_killed.emit()
	stop_sounds()
	queue_free()

func die():
	AudioManager.play_sound(hurt_sound)
	sprite.play("death")
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", Color(10, 10, 10, 1), 1.0)
	stop_sounds()
	queue_free()

func stop_sounds() -> void:
	AudioManager.stop(fire_sound)
	AudioManager.stop(ice_sound)

func show_fire() -> void:
	AudioManager.play_sfx_loop(fire_sound)
	fire_fx.show()

func hide_fire() -> void:
	AudioManager.stop(fire_sound)
	fire_fx.hide()

func show_ice() -> void:
	AudioManager.play_sfx_loop(ice_sound)
	ice_fx.show()

func hide_ice() -> void:
	AudioManager.stop(ice_sound)
	ice_fx.hide()

func show_poison() -> void:
	poison_fx.show()

func hide_poison() -> void:
	poison_fx.hide()
