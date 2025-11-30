extends Button
class_name UIButton

@onready var shader = preload("res://shaders/2d_highlight.gdshader")

func _ready() -> void:
	var new_material = ShaderMaterial.new()
	new_material.shader = shader
	self.material = new_material
	
	self.get_material().set_shader_parameter("size_effect", 0.3)
	self.get_material().set_shader_parameter("speed", 0)
	self.get_material().set_shader_parameter("highlight_strength", 0.75)
	self.get_material().set_shader_parameter("is_horizontal", true)
	
	self.focus_entered.connect(_on_self_focus_entered)
	self.focus_exited.connect(_on_self_focus_exited)
	self.mouse_entered.connect(_on_self_mouse_entered)
	self.mouse_exited.connect(_on_self_mouse_exited)

func _on_self_focus_entered() -> void:
	self.get_material().set_shader_parameter("speed", 2)

func _on_self_focus_exited() -> void:
	self.get_material().set_shader_parameter("speed", 0)

func _on_self_mouse_entered() -> void:
	self.grab_focus()

func _on_self_mouse_exited() -> void:
	self.grab_focus()
