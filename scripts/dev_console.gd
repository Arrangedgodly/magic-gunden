extends Control

@onready var main_menu: VBoxContainer = %MainMenu
@onready var powerup_menu: HBoxContainer = %PowerupMenu
@onready var enemy_button: Button = %Enemy
@onready var gem_button: Button = %Gem
@onready var powerup_button: Button = %Powerup
@onready var back_button: Button = %Back
@onready var enemy_manager: EnemyManager
@onready var pickup_manager: PickupManager

@onready var magnet_button: Button = %Magnet
@onready var pierce_button: Button = %Pierce
@onready var ricochet_button: Button = %Ricochet
@onready var stomp_button: Button = %Stomp
@onready var poison_button: Button = %Poison
@onready var auto_aim_button: Button = %AutoAim
@onready var flames_button: Button = %Flames
@onready var free_ammo_button: Button = %FreeAmmo
@onready var ice_button: Button = %Ice
@onready var jump_button: Button = %Jump
@onready var time_pause_button: Button = %TimePause
@onready var grenade_button: Button = %Grenade
@onready var four_way_shot_button: Button = %FourWayShot

signal console_opened(is_open: bool)

func _ready() -> void:
	hide()
	enemy_manager = get_node("/root/MagicGarden/Systems/EnemyManager")
	pickup_manager = get_node("/root/MagicGarden/Systems/PickupManager")
	
	self.visible = false
	powerup_menu.visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	enemy_button.pressed.connect(_on_spawn_enemy)
	gem_button.pressed.connect(_on_spawn_yoyo)
	powerup_button.pressed.connect(_on_powerup_menu_open)
	
	back_button.pressed.connect(_on_back_to_main)
	magnet_button.pressed.connect(_on_spawn_pickup.bind(0))
	pierce_button.pressed.connect(_on_spawn_pickup.bind(1))
	ricochet_button.pressed.connect(_on_spawn_pickup.bind(2))
	stomp_button.pressed.connect(_on_spawn_pickup.bind(3))
	poison_button.pressed.connect(_on_spawn_pickup.bind(4))
	auto_aim_button.pressed.connect(_on_spawn_pickup.bind(5))
	flames_button.pressed.connect(_on_spawn_pickup.bind(6))
	free_ammo_button.pressed.connect(_on_spawn_pickup.bind(7))
	ice_button.pressed.connect(_on_spawn_pickup.bind(8))
	jump_button.pressed.connect(_on_spawn_pickup.bind(9))
	time_pause_button.pressed.connect(_on_spawn_pickup.bind(10))
	grenade_button.pressed.connect(_on_spawn_pickup.bind(11))
	four_way_shot_button.pressed.connect(_on_spawn_pickup.bind(12))
	
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

func _on_powerup_menu_open() -> void:
	main_menu.visible = false
	powerup_menu.visible = true
	magnet_button.grab_focus()

func _on_back_to_main() -> void:
	show_main_menu()

func _on_spawn_enemy() -> void:
	enemy_manager.spawn_enemy()

func _on_spawn_pickup(index: int) -> void:
	pickup_manager.force_spawn_pickup(index)

func _on_spawn_yoyo() -> void:
	pickup_manager.spawn_gem()
