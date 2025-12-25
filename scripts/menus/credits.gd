extends Control

@onready var c_box: VBoxContainer = $CenterContainer/VBoxContainer
@onready var center_container: Control = $CenterContainer
@onready var particle_effects: Node2D = $"CenterContainer/Particle Effects"
@onready var exit_button: Button = %Exit

@export var credits_music: AudioStream

var credits = []
var scroll_tween: Tween
var scroll_speed: float = 100.0

func _ready() -> void:
	DebugLogger.log_info("=== CREDITS READY START ===")
	AudioManager.play_music(credits_music)
	
	c_box.position.y += get_viewport_rect().size.y
	
	exit_button.pressed.connect(return_to_main_menu)
	
	_start_particles()
	
	move_credits()
	DebugLogger.log_info("=== CREDITS READY COMPLETE ===")
	
func _process(_delta: float) -> void:
	if scroll_tween and scroll_tween.is_valid():
		if Input.is_action_pressed("ui_accept"):
			scroll_tween.set_speed_scale(10.0)
		else:
			scroll_tween.set_speed_scale(1.0)
		
	if Input.is_action_just_pressed("ui_cancel"):
		return_to_main_menu()
	
func _start_particles() -> void:
	DebugLogger.log_info("Starting credit particles...")
	var particles = particle_effects.get_children()
	for particle in particles:
		particle.emitting = true
	DebugLogger.log_info("Credit particles started")

func move_credits() -> void:
	DebugLogger.log_info("Moving credits...")
	var target_y = -c_box.size.y
	var start_y = c_box.position.y
	var distance = abs(start_y - target_y)
	var duration = distance / scroll_speed

	scroll_tween = create_tween()
	scroll_tween.tween_property(c_box, "position:y", target_y, duration)
	scroll_tween.finished.connect(fade_credits)
	DebugLogger.log_info("Credits moved successfully")

func return_to_main_menu() -> void:
	DebugLogger.log_info("Returning to main menu from credits")
	AudioManager.stop(credits_music)
	LoadManager.quick_load("res://scenes/menus/main_menu.tscn")

func fade_credits() -> void:
	DebugLogger.log_info("Fading credits...")
	var tween = create_tween()
	tween.tween_property(center_container, "modulate:a", 0, 2)
	await tween.finished
	return_to_main_menu()
