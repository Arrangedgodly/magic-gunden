extends Node2D
class_name GameManager

@onready var player: CharacterBody2D = %Player
@onready var pause_screen: Control = %PauseScreen
@onready var tutorial: Tutorial = %Tutorial
@onready var pickup_manager: PickupManager = %PickupManager
@onready var enemy_manager: EnemyManager = %EnemyManager
@onready var capture_point_manager: CapturePointManager = %CapturePointManager
@onready var powerup_manager: PowerupManager = %PowerupManager
@onready var score_manager: ScoreManager = %ScoreManager
@onready var ammo_manager: AmmoManager = %AmmoManager

@export var background_music: AudioStream

var animation_speed = 5
var game_started: bool = false
var level = 1
var game_paused : bool
var tutorial_mode: bool = false

signal level_changed(new_level: int)
signal game_ended
signal ui_visible(visible: bool)
signal tutorial_player_died

func _ready() -> void:
	ErrorHandler.mark_safe_point("GameManager._ready START")
	DebugLogger.log_info("=== GAME MANAGER READY START ===")
	
	DebugLogger.log_info("Connecting pause screen signals...")
	pause_screen.main_menu_pressed.connect(_on_main_menu_pressed)
	pause_screen.restart_pressed.connect(_on_restart_pressed)
	ErrorHandler.mark_safe_point("GameManager._ready signals connected")
	
	DebugLogger.log_info("Calling deferred initialize...")
	call_deferred("_initialize")

func _initialize() -> void:
	ErrorHandler.mark_safe_point("GameManager._initialize START")
	DebugLogger.log_info("=== GAME MANAGER INITIALIZE START ===")
	
	if tutorial:
		DebugLogger.log_info("Tutorial found, checking settings...")
		if tutorial.tutorial_save:
			DebugLogger.log_info("Tutorial save exists, show_tutorial: " + str(tutorial.tutorial_save.show_tutorial))
		else:
			DebugLogger.log_warning("Tutorial save is null")
			
		if not (tutorial and tutorial.tutorial_save and tutorial.tutorial_save.show_tutorial):
			DebugLogger.log_info("Initializing first spawn...")
			capture_point_manager.initialize_first_spawn()
		else:
			DebugLogger.log_info("Skipping first spawn - tutorial active")
	else:
		DebugLogger.log_warning("Tutorial not found")
		capture_point_manager.initialize_first_spawn()
	
	ErrorHandler.mark_safe_point("GameManager._initialize COMPLETE")
	DebugLogger.log_info("=== GAME MANAGER INITIALIZE COMPLETE ===")

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("move-left") or Input.is_action_just_pressed("move-right") \
	or Input.is_action_just_pressed("move-up") or Input.is_action_just_pressed("move-down"):
		if not game_started:
			start_game()

func start_game():
	if game_started:
		return
		
	game_started = true
	
	if not tutorial_mode:
		AudioManager.play_music(background_music)
		player.move_timer.start()
		capture_point_manager.start_capture_systems()
		score_manager.time_counter.start()
		enemy_manager.start_enemy_systems()
	else:
		player.move_timer.start()

func start_normal_gameplay_loop():
	tutorial_mode = false
	
	if background_music:
		AudioManager.play_music(background_music)
	
	if capture_point_manager:
		capture_point_manager.disable_tutorial_mode()
	
	score_manager.time_counter.start()
	enemy_manager.start_enemy_systems()

func end_game():
	AudioManager.stop(background_music)
	player.move_timer.stop()
	capture_point_manager.stop_capture_systems()
	score_manager.time_counter.stop()
	enemy_manager.stop_enemy_systems()
	pause_screen.disable()
	game_ended.emit()
	score_manager.save_game()

func increase_level():
	level += 1
	level_changed.emit(level)

func _on_pause_screen_visibility_changed() -> void:
	if not game_paused:
		AudioManager.pause(background_music)
		game_paused = true
		ui_visible.emit(false)
		if tutorial:
			if tutorial.visible:
				tutorial.hide()
	else:
		AudioManager.resume(background_music)
		game_paused = false
		ui_visible.emit(true)
		if tutorial and not tutorial.visible:
			tutorial.show()

func _on_main_menu_pressed() -> void:
	AudioManager.stop(background_music)

func _on_restart_pressed() -> void:
	AudioManager.stop(background_music)

func handle_tutorial_death() -> void:
	tutorial_player_died.emit()
