extends CanvasLayer

@onready var container: Control = $Control
@onready var enemy_button: Button = $Control/VBoxContainer/Enemy
@onready var magnet_button: Button = $Control/VBoxContainer/Magnet
@onready var pierce_button: Button = $Control/VBoxContainer/Pierce
@onready var ricochet_button: Button = $Control/VBoxContainer/Ricochet
@onready var stomp_button: Button = $Control/VBoxContainer/Stomp
@onready var enemy_manager: EnemyManager = %EnemyManager
@onready var pickup_manager: PickupManager = %PickupManager

func _ready() -> void:
	container.visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	enemy_button.pressed.connect(_on_spawn_enemy)
	magnet_button.pressed.connect(_on_spawn_pickup.bind(0))
	pierce_button.pressed.connect(_on_spawn_pickup.bind(1))
	ricochet_button.pressed.connect(_on_spawn_pickup.bind(2))
	stomp_button.pressed.connect(_on_spawn_pickup.bind(3))
	
func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("console"):
		toggle_console()

func toggle_console() -> void:
	container.visible = not container.visible
	
	get_tree().paused = container.visible

func _on_spawn_enemy() -> void:
	enemy_manager.spawn_enemy()

func _on_spawn_pickup(index: int) -> void:
	pickup_manager.force_spawn_pickup(index)
