extends AnimatedSprite2D
class_name Gem

@onready var game_manager = get_parent()
@onready var gem_area: Area2D = %GemArea
@onready var pickup_manager: PickupManager
@onready var player: Player

var pickup_sfx: AudioStream = preload("res://assets/sounds/sfx/Retro PickUp Coin 04.wav")

var can_pickup: bool
var collision_active: bool = false
var point_value: int
var ammo_value: int

signal captured(point_value: int, ammo_value: int)


func _ready() -> void:
	add_to_group("gems")
	add_to_group("laser_exception")
	pickup_manager = get_node("/root/MagicGarden/Systems/PickupManager")
	player = get_node("/root/MagicGarden/World/GameplayArea/Player")
	gem_area.body_entered.connect(_on_area_2d_body_entered)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if can_pickup:
		if body is Player:
			pickup_manager.reset_regen_gem()
			AudioManager.play_sound(pickup_sfx)
			queue_free()
		return
	
	if body is Player:
		if collision_active:
			player.die()
	
func negate_pickup():
	can_pickup = false
	collision_active = false
	
func enable_pickup():
	can_pickup = true
	collision_active = false

func activate_collision():
	collision_active = true

func flash(flash_color: Color):
	var shader_material = self.get_material()
	shader_material.set_shader_parameter("flash_color", flash_color)
	shader_material.set_shader_parameter("flash_modifier", .75)
	await get_tree().create_timer(.125).timeout
	shader_material.set_shader_parameter("flash_modifier", 0)
	await get_tree().create_timer(.125).timeout
	shader_material.set_shader_parameter("flash_modifier", .75)
	await get_tree().create_timer(.125).timeout
	shader_material.set_shader_parameter("flash_modifier", 0)

func on_capture() -> void:
	captured.emit(point_value, ammo_value)
