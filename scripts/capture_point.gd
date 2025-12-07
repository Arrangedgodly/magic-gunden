extends AnimatedSprite2D

@onready var rainbow_shader = preload("res://shaders/rainbow_gradient.gdshader")

var detected_body = null

func _ready() -> void:
	add_to_group("capture")

func remove():
	queue_free()

func check_detected_body() -> Node2D:
	return detected_body

func _on_area_2d_area_entered(area: Area2D) -> void:
	var pickup = area.get_parent()
	if pickup.is_in_group("equipped"):
		detected_body = pickup

func _on_area_2d_area_exited(area: Area2D) -> void:
	var pickup = area.get_parent()
	if detected_body == pickup:
		detected_body = null
	
func flash():
	set_rainbow_shader()
	
	material.set_shader_parameter("strength", 0.75)
	material.set_shader_parameter("speed", 1.0)
	
	await get_tree().create_timer(3).timeout
	material = null

func set_rainbow_shader() -> void:
	var new_material = ShaderMaterial.new()
	new_material.shader = rainbow_shader
	material = new_material
