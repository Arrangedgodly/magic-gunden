extends Area2D

var laser_sprite_scene = preload("res://scenes/effects/laser_sprite.tscn")

@onready var collision_shape: CollisionShape2D = %Collision
@onready var laser_sound: AudioStream = preload("res://assets/sounds/sfx/sci-fi_weapon_blaster_laser_boom_01.wav")

var direction := Vector2.RIGHT
var timer: Timer
var ray: RayCast2D

const FPS = 15.0
const TARGET_SIZE = 64.0 
const ASSET_SIZE = 48.0
const MAX_LENGTH = 1000.0

func _ready() -> void:
	timer = Timer.new()
	timer.wait_time = 0.3
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)
	
	ray = RayCast2D.new()
	ray.target_position = Vector2(MAX_LENGTH, 0)
	ray.collide_with_areas = true
	ray.collide_with_bodies = true
	add_child(ray)
	
	timer.start()
	AudioManager.play_sound(laser_sound)

func setup(pos: Vector2, new_direction: Vector2) -> void:
	position = pos
	direction = new_direction
	rotation = new_direction.angle()
	
	var beam_length = get_distance_to_wall()
	
	construct_beam(beam_length)
	
	update_collision_shape(beam_length)

func get_distance_to_wall() -> float:
	ray.force_raycast_update()
	
	while ray.is_colliding():
		var collider = ray.get_collider()
		
		if collider.is_in_group("laser_exception"):
			ray.add_exception(collider)
			ray.force_raycast_update()
		else:
			return to_local(ray.get_collision_point()).length()
			
	return MAX_LENGTH

func construct_beam(length: float) -> void:
	var scale_factor = TARGET_SIZE / ASSET_SIZE
	var sprite_scale = Vector2(scale_factor, scale_factor)
	
	var start_sprite = laser_sprite_scene.instantiate()
	add_child(start_sprite)
	start_sprite.scale = sprite_scale
	start_sprite.play("fire")
	start_sprite.flip_h = true 
	start_sprite.position = Vector2(TARGET_SIZE / 2.0, 0)
	
	var end_sprite = laser_sprite_scene.instantiate()
	add_child(end_sprite)
	end_sprite.scale = sprite_scale
	end_sprite.play("end")
	end_sprite.position = Vector2(length - (TARGET_SIZE / 2.0), 0)
	
	var current_x = TARGET_SIZE
	var end_limit = length - TARGET_SIZE
	
	while current_x < end_limit:
		var mid_sprite = laser_sprite_scene.instantiate()
		add_child(mid_sprite)
		mid_sprite.scale = sprite_scale
		mid_sprite.play("middle")
		mid_sprite.position = Vector2(current_x + (TARGET_SIZE / 2.0), 0)
		
		current_x += TARGET_SIZE

func update_collision_shape(length: float) -> void:
	var rect = RectangleShape2D.new()
	rect.size = Vector2(length, TARGET_SIZE * 0.5) 
	collision_shape.shape = rect
	collision_shape.position = Vector2(length / 2.0, 0)

func _on_timer_timeout() -> void:
	queue_free()

func _physics_process(_delta: float) -> void:
	var bodies = get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("mobs") and body.has_method("kill"):
			body.kill()
