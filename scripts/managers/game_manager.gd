extends Node2D
class_name GameManager

@onready var player: CharacterBody2D = %Player
@onready var pause_screen: Node2D = %PauseScreen
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
var is_tutorial_mode: bool = false
var tutorial_mode_active: bool = false

signal level_changed(new_level: int)
signal game_ended
signal ui_visible(visible: bool)

func _ready() -> void:
	pause_screen.main_menu_pressed.connect(_on_main_menu_pressed)
	pause_screen.restart_pressed.connect(_on_restart_pressed)
	call_deferred("_initialize")

func _initialize() -> void:
	if not (tutorial and tutorial.tutorial_save and tutorial.tutorial_save.show_tutorial):
		capture_point_manager.initialize_first_spawn()

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("move-left") or Input.is_action_just_pressed("move-right") \
	or Input.is_action_just_pressed("move-up") or Input.is_action_just_pressed("move-down"):
		if not game_started:
			start_game()

func start_game():
	if game_started:
		return
		
	game_started = true
	
	if not is_tutorial_mode:
		AudioManager.play_music(background_music)
		player.move_timer.start()
		capture_point_manager.start_capture_systems()
		score_manager.time_counter.start()
		enemy_manager.start_enemy_systems()
	else:
		player.move_timer.start()

func start_normal_gameplay_loop():
	is_tutorial_mode = false
	tutorial_mode_active = false
	
	if background_music:
		AudioManager.play_music(background_music)
	
	if capture_point_manager:
		capture_point_manager.disable_tutorial_mode()
		capture_point_manager.start_capture_systems()
	
	score_manager.time_counter.start()
	enemy_manager.start_enemy_systems()

func end_game():
	AudioManager.stop(background_music)
	player.move_timer.stop()
	capture_point_manager.stop_capture_systems()
	score_manager.time_counter.stop()
	enemy_manager.stop_enemy_systems()
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
