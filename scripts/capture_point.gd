extends AnimatedSprite2D

var detected_body = null

func _ready() -> void:
	add_to_group("capture")
	self.get_material().set_shader_parameter("strength", 0)

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
	self.get_material().set_shader_parameter("strength", 0.75)
	await get_tree().create_timer(3).timeout
