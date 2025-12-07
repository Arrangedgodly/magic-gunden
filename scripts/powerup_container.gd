extends HBoxContainer

var powerup_manager: PowerupManager
var powerup_widget_scene = preload("res://scenes/powerup_widget.tscn")
var powerup_icons = {
	"Ricochet" = preload("res://assets/items/powerups/ricochet-new.png"),
	"Pierce" = preload("res://assets/items/powerups/pierce-new.png"),
	"Magnet" = preload("res://assets/items/powerups/magnet.png"),
	"Stomp" = preload("res://assets/items/powerups/stomp.png"),
	"Poison" = preload("res://assets/items/powerups/poison-new.png"),
	"AutoAim" = preload("res://assets/items/powerups/auto_aim.png"),
	"Flames" = preload("res://assets/items/powerups/flames-new.png"),
	"FreeAmmo" = preload("res://assets/items/powerups/free-ammo.png"),
	"Ice" = preload("res://assets/items/powerups/ice-new.png"),
	"Jump" = preload("res://assets/items/powerups/jump.png"),
	"TimePause" = preload("res://assets/items/powerups/pause.png")
}
var active_widgets: Dictionary = {}

func _ready() -> void:
	powerup_manager = get_node("/root/MagicGarden/Systems/PowerupManager")
	powerup_manager.powerup_activated.connect(_on_powerup_activated)

func _on_powerup_activated(p_name: String) -> void:
	if active_widgets.has(p_name):
		return

	var timer_node = powerup_manager.get_powerup_timer(p_name)
	
	if not timer_node:
		push_error("UI: No timer found for " + p_name)
		return

	var new_widget = powerup_widget_scene.instantiate()
	add_child(new_widget)
	
	var icon = powerup_icons.get(p_name)
	
	new_widget.setup(p_name, timer_node, icon)
	
	active_widgets[p_name] = new_widget
	
	new_widget.tree_exiting.connect(func(): active_widgets.erase(p_name))
