extends Node2D
@onready var blue: TileMapLayer = $Blue
@onready var red: TileMapLayer = $Red
@onready var green: TileMapLayer = $Green

var level : int

func _ready() -> void:
	level = 1
	blue.enabled = true
	
func _on_game_manager_level_changed(new_level: int) -> void:
	_disable_backgrounds()
	level = new_level
	if level == 1:
		blue.enabled = true
	elif level == 2:
		green.enabled = true
	elif level == 3:
		red.enabled = true
		
func _disable_backgrounds():
	blue.enabled = false
	red.enabled = false
	green.enabled = false
