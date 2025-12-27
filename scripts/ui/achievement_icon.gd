extends TextureRect

signal hovered(data: AchievementData)
signal unhovered

@export var hidden_icon: Texture2D

var _data: AchievementData

func _ready() -> void:
	mouse_entered.connect(_on_interaction_start)
	mouse_exited.connect(_on_interaction_end)
	
	focus_entered.connect(_on_interaction_start)
	focus_exited.connect(_on_interaction_end)

func setup(data: AchievementData) -> void:
	_data = data
	
	(material as ShaderMaterial).set_shader_parameter("is_locked", false)
	
	if data.is_unlocked:
		texture = data.icon
		
	elif data.hidden:
		texture = hidden_icon
		
	else:
		texture = data.icon
		(material as ShaderMaterial).set_shader_parameter("is_locked", true)

func _on_interaction_start() -> void:
	hovered.emit(_data)

func _on_interaction_end() -> void:
	unhovered.emit()
