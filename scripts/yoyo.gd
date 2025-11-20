extends AnimatedSprite2D

@onready var game_manager = get_parent()
@onready var yoyo_area: Area2D = $YoyoArea

var can_pickup: bool
var is_fresh_trail: bool = false

func _ready() -> void:
	yoyo_area.body_entered.connect(_on_area_2d_body_entered)
	yoyo_area.body_exited.connect(_on_area_2d_body_exited)

func _on_area_2d_body_entered(_body: Node2D) -> void:
	if can_pickup:
		game_manager.reset_regen_yoyo()
		queue_free()
	else:
		if is_fresh_trail:
			return
			
		game_manager.kill_player()

func _on_area_2d_body_exited(_body: Node2D) -> void:
	if is_fresh_trail and not can_pickup:
		is_fresh_trail = false
	
func negate_pickup():
	can_pickup = false
	is_fresh_trail = true
	
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
