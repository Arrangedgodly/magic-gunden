extends AnimatedSprite2D
@onready var game_manager = get_parent()
@onready var player: CharacterBody2D = $"../../Player"
@onready var detection: RayCast2D = $Detection

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

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body == player:
		game_manager.kill_player()
	else:
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
			await self.animation_looped
			position += random_direction * 32
			move_direction(random_direction)

func idle_direction(dir):
	if dir == right:
		self.flip_h = false
		self.play("idle_right")
	elif dir == left:
		self.flip_h = true
		self.play("idle_right")
	elif dir == up:
		self.play("idle_up")
	elif dir == down:
		self.play("idle_down")

func move_direction(dir):
	if dir == right:
		self.flip_h = false
		self.play("move_right")
		await self.animation_finished
		self.play("idle_right")
	elif dir == left:
		self.flip_h = true
		self.play("move_right")
		await self.animation_finished
		self.play("idle_right")
	elif dir == up:
		self.play("move_up")
		await self.animation_finished
		self.play("idle_up")
	elif dir == down:
		self.play("move_down")
		await self.animation_finished
		self.play("idle_down")


func _on_area_2d_area_entered(area: Area2D) -> void:
	var projectiles = get_tree().get_nodes_in_group("projectile")
	for projectile in projectiles:
		if area == projectile:
			kill()

func kill():
	AudioManager.play_sound(hurt_sound)
	game_manager.increase_kill_count()
	self.play("death")
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(10, 10, 10, 1), 1.0)
	was_killed.emit()
	queue_free()
