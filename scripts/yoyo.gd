extends AnimatedSprite2D

@onready var game_manager = get_parent()
var can_pickup: bool

func _on_area_2d_body_entered(_body: Node2D) -> void:
	if can_pickup:
		game_manager.reset_regen_yoyo()
		queue_free()
	else:
		game_manager.kill_player()
	
func negate_pickup():
	can_pickup = false
	
func enable_pickup():
	can_pickup = true

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
