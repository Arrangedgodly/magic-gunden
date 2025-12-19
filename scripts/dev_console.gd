extends Control

@onready var main_menu: VBoxContainer = %MainMenu
@onready var powerup_menu: HBoxContainer = %PowerupMenu
@onready var enemy_button: Button = %Enemy
@onready var gem_button: Button = %Gem
@onready var trail_gem_button: Button = %TrailGem
@onready var powerup_button: Button = %Powerup
@onready var enemy_manager: EnemyManager
@onready var pickup_manager: PickupManager
@onready var powerup_manager: PowerupManager
@onready var trail_manager: TrailManager

const BUTTON_SCENE = preload("res://scenes/ui/ui_button.tscn")
const BUTTON_FONT = preload("res://assets/Stacked pixel.ttf")

signal console_opened(is_open: bool)

func _ready() -> void:
	hide()
	enemy_manager = get_node("/root/MagicGarden/Systems/EnemyManager")
	pickup_manager = get_node("/root/MagicGarden/Systems/PickupManager")
	powerup_manager = get_node("/root/MagicGarden/Systems/PowerupManager")
	trail_manager = get_node("/root/MagicGarden/Systems/TrailManager")
	
	self.visible = false
	powerup_menu.visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	enemy_button.pressed.connect(_on_spawn_enemy)
	gem_button.pressed.connect(_on_spawn_gem)
	trail_gem_button.pressed.connect(_on_spawn_trail_gem)
	powerup_button.pressed.connect(_on_powerup_menu_open)
	
	_generate_powerup_ui()

func _generate_powerup_ui() -> void:
	for child in powerup_menu.get_children():
		child.queue_free()
		
	var powerup_data = []
	for scene in powerup_manager.available_pickups:
		var file_name = scene.resource_path.get_file().get_basename()
		var nice_name = file_name.replace("_", " ").capitalize()
		
		powerup_data.append({
			"name": nice_name,
			"scene": scene
		})

	powerup_data.sort_custom(func(a, b): return a.name < b.name)

	var total_items = powerup_data.size() + 1 
	var columns_count = 3
	var items_per_col = ceil(total_items / float(columns_count))
	
	var current_col_vbox = _create_column_container()
	powerup_menu.add_child(current_col_vbox)
	
	var current_item_count = 0
	
	for data in powerup_data:
		if current_item_count >= items_per_col:
			current_col_vbox = _create_column_container()
			powerup_menu.add_child(current_col_vbox)
			current_item_count = 0
			
		var btn = _create_scene_button(data.name)
		
		btn.pressed.connect(_on_spawn_pickup.bind(data.scene))
		
		current_col_vbox.add_child(btn)
		current_item_count += 1

	if current_item_count >= items_per_col:
		current_col_vbox = _create_column_container()
		powerup_menu.add_child(current_col_vbox)
	
	var back_btn = _create_scene_button("Go Back")
	back_btn.pressed.connect(_on_back_to_main)
	current_col_vbox.add_child(back_btn)

func _create_column_container() -> VBoxContainer:
	var vbox = VBoxContainer.new()
	vbox.size_flags_vertical = Control.SIZE_SHRINK_CENTER 
	vbox.add_theme_constant_override("separation", 25)
	return vbox

func _create_scene_button(text_label: String) -> Button:
	var btn = BUTTON_SCENE.instantiate()
	btn.text = text_label
	btn.add_theme_font_override("font", BUTTON_FONT)
	btn.add_theme_font_size_override("font_size", 32)
	return btn
	
func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("console"):
		toggle_console()

func toggle_console() -> void:
	self.visible = not self.visible
	
	if self.visible:
		show()
		show_main_menu()
		console_opened.emit(true)
	else:
		hide()
		console_opened.emit(false)
	
	get_tree().paused = self.visible

func show_main_menu() -> void:
	main_menu.visible = true
	powerup_menu.visible = false
	enemy_button.grab_focus()

func _on_spawn_trail_gem() -> void:
	trail_manager.create_trail_segment()

func _on_powerup_menu_open() -> void:
	main_menu.visible = false
	powerup_menu.visible = true
	
	if powerup_menu.get_child_count() > 0:
		var col1 = powerup_menu.get_child(0)
		if col1.get_child_count() > 0:
			col1.get_child(0).grab_focus()

func _on_back_to_main() -> void:
	show_main_menu()

func _on_spawn_enemy() -> void:
	enemy_manager.spawn_enemy()

func _on_spawn_pickup(scene: PackedScene) -> void:
	pickup_manager.force_spawn_pickup(scene)

func _on_spawn_gem() -> void:
	pickup_manager.spawn_gem()
