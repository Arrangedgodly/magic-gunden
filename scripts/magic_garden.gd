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

func _ready() -> void:
	_initialize_managers()
	
	_connect_scene_signals()
	
	_setup_tutorial()

func _initialize_managers() -> void:
	if GameManager:
		GameManager.initialize_game_scene(self, player, move_timer, pause_screen, time_counter)
	
	if TrailManager:
		TrailManager.initialize(self, player)
	
	if EnemyManager:
		EnemyManager.initialize(player, enemy_spawn, enemy_move)
	
	if CapturePointManager:
		CapturePointManager.initialize(capture_timer, capture_animation)
	
	if PickupManager:
		PickupManager.initialize(player)
	
	if PowerupManager:
		PowerupManager.initialize(player, stomp_timer, magnet_timer, pierce_timer)
	
	if ScoreManager:
		ScoreManager.reset_all()

func _connect_scene_signals() -> void:
	
	var ui = $Camera2D/UI if has_node("Camera2D/UI") else null
	if ui and GameManager:
		GameManager.update_score.connect(ui._on_game_manager_update_score)
		GameManager.ui_visible.connect(ui._on_game_manager_ui_visible)
		GameManager.current_ammo.connect(ui._on_game_manager_current_ammo)
		GameManager.killstreak.connect(ui._on_game_manager_killstreak)
	
	var end_game_screen = $EndGameScreen if has_node("EndGameScreen") else null
	if end_game_screen and GameManager:
		GameManager.game_ended.connect(end_game_screen._on_game_manager_game_ended)
		GameManager.new_highscore.connect(end_game_screen._on_game_manager_new_highscore)
		GameManager.new_high_killcount.connect(end_game_screen._on_game_manager_new_high_killcount)
		GameManager.new_high_time_alive.connect(end_game_screen._on_game_manager_new_high_time_alive)
		GameManager.new_high_gems_captured.connect(end_game_screen._on_game_manager_new_high_gems_captured)

func _setup_tutorial() -> void:
	var tutorial = $Tutorial if has_node("Tutorial") else null
	if tutorial:
		tutorial.tutorial_finished.connect(_on_tutorial_finished)

func _on_tutorial_finished() -> void:
	# Tutorial finished, UI elements should show themselves
	pass
