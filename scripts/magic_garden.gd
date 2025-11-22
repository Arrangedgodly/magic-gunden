extends Node2D

@onready var player: CharacterBody2D = %Player
@onready var move_timer: Timer = $MoveTimer
@onready var pause_screen: Node2D = $PauseScreen
@onready var time_counter: Timer = $GameManager/TimeCounter
@onready var capture_point_manager_node: Node2D = $CapturePointManager
@onready var enemy_manager_node: Node2D = $EnemyManager
@onready var enemy_spawn: Timer = $EnemySpawn
@onready var enemy_move: Timer = $EnemyMove
@onready var capture_timer: Timer = $CapturePointTimer
@onready var capture_animation: Timer = $CapturePointAnimation
@onready var stomp_timer: Timer = $StompTimer
@onready var magnet_timer: Timer = $MagnetTimer
@onready var pierce_timer: Timer = $PierceTimer
@onready var end_game_screen: Control = $EndGameScreen
@onready var game_manager_scene: Node2D = %GameManager

func _ready() -> void:
	_initialize_managers()
	
	_setup_tutorial()

func _initialize_managers() -> void:
	if GameManager:
		GameManager.initialize_game_scene(game_manager_scene, player, move_timer, pause_screen, time_counter)
	
	if TrailManager:
		TrailManager.initialize(game_manager_scene, player)
	
	if EnemyManager:
		EnemyManager.initialize(game_manager_scene, player, enemy_spawn, enemy_move)
	
	if CapturePointManager:
		CapturePointManager.initialize(game_manager_scene, capture_timer, capture_animation)
	
	if PickupManager:
		PickupManager.initialize(game_manager_scene, player)
	
	if PowerupManager:
		PowerupManager.initialize(player, stomp_timer, magnet_timer, pierce_timer)
	
	if ScoreManager:
		ScoreManager.reset_all()
	
	end_game_screen.initialize()

func _setup_tutorial() -> void:
	var tutorial = $Tutorial if has_node("Tutorial") else null
	if tutorial:
		tutorial.tutorial_finished.connect(_on_tutorial_finished)

func _on_tutorial_finished() -> void:
	# Tutorial finished, UI elements should show themselves
	pass
