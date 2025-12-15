extends Button
class_name UIButton

@onready var shader = preload("res://shaders/2d_highlight.gdshader")
@onready var confirm_sound = preload("res://assets/sounds/sfx/interface/confirm_style_3_003.wav")
@onready var hover_sound = preload("res://assets/sounds/sfx/interface/cursor_style_3.wav")

func _ready() -> void:
	var new_material = ShaderMaterial.new()
	new_material.shader = shader
	self.material = new_material
	
	self.get_material().set_shader_parameter("size_effect", 0.3)
	self.get_material().set_shader_parameter("speed", 0)
	self.get_material().set_shader_parameter("highlight_strength", 0.75)
	self.get_material().set_shader_parameter("is_horizontal", true)
	
	focus_entered.connect(_on_self_focus_entered)
	focus_exited.connect(_on_self_focus_exited)
	mouse_entered.connect(_on_self_mouse_entered)
	mouse_exited.connect(_on_self_mouse_exited)
	pressed.connect(_on_self_pressed)

func _on_self_focus_entered() -> void:
	AudioManager.play_sound(hover_sound)
	self.get_material().set_shader_parameter("speed", 2)

func _on_self_focus_exited() -> void:
	self.get_material().set_shader_parameter("speed", 0)

func _on_self_mouse_entered() -> void:
	AudioManager.play_sound(hover_sound)
	self.grab_focus()

func _on_self_mouse_exited() -> void:
	self.grab_focus()

func _on_self_pressed() -> void:
	AudioManager.play_sound(confirm_sound)
