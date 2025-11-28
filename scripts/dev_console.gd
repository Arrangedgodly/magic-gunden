extends CanvasLayer

@onready var container: Control = $Control
@onready var main_menu: VBoxContainer = $Control/MainMenu
@onready var powerup_menu: VBoxContainer = $Control/PowerupMenu
@onready var enemy_button: Button = $Control/MainMenu/Enemy
@onready var gem_button: Button = $Control/MainMenu/Gem
@onready var powerup_button: Button = $Control/MainMenu/Powerup
@onready var back_button: Button = $Control/PowerupMenu/Back
@onready var enemy_manager: EnemyManager = %EnemyManager
@onready var pickup_manager: PickupManager = %PickupManager

@onready var magnet_button: Button = $Control/PowerupMenu/Magnet
@onready var pierce_button: Button = $Control/PowerupMenu/Pierce
@onready var ricochet_button: Button = $Control/PowerupMenu/Ricochet
@onready var stomp_button: Button = $Control/PowerupMenu/Stomp
@onready var poison_button: Button = $Control/PowerupMenu/Poison
@onready var auto_aim_button: Button = $Control/PowerupMenu/AutoAim
@onready var flames_button: Button = $Control/PowerupMenu/Flames
@onready var free_ammo_button: Button = $Control/PowerupMenu/FreeAmmo
@onready var ice_button: Button = $Control/PowerupMenu/Ice
@onready var jump_button: Button = $Control/PowerupMenu/Jump
@onready var time_pause_button: Button = $Control/PowerupMenu/TimePause

func _ready() -> void:
	container.visible = false
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
	
func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("console"):
		toggle_console()

func toggle_console() -> void:
	container.visible = not container.visible
	
	if container.visible:
		show_main_menu()
	
	get_tree().paused = container.visible

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
	pickup_manager.force_spawn_yoyo()
