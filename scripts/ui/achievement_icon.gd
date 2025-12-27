extends TextureRect

signal hovered(data: AchievementData)
signal unhovered

@export var hidden_icon: Texture2D

var _data: AchievementData

func _ready() -> void:
	if material:
		material = material.duplicate()
		
	mouse_entered.connect(_on_interaction_start)
	mouse_exited.connect(_on_interaction_end)
	
	focus_entered.connect(_on_interaction_start)
	focus_exited.connect(_on_interaction_end)

func setup(data: AchievementData) -> void:
	_data = data
	
	material.set_shader_parameter("is_locked", not data.is_unlocked)
	
	if data.icon:
		texture = data.icon
	else:
		texture = hidden_icon

func _on_interaction_start() -> void:
	hovered.emit(_data)

func _on_interaction_end() -> void:
	unhovered.emit()
