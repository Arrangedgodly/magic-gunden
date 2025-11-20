extends Control

@onready var c_box: VBoxContainer = $CenterContainer/VBoxContainer
@onready var center_container: Control = $CenterContainer
@onready var particle_effects: Node2D = $"CenterContainer/Particle Effects"

@export var credits_music: AudioStream

var credits = []
var can_move : bool = false
var scroll_tween: Tween

func _ready() -> void:
	AudioManager.play_music(credits_music)
	c_box.position.y += get_viewport_rect().size.y
	can_move = true
	
func _process(_delta: float) -> void:
	if can_move:
		move_credits()
	
	if scroll_tween and scroll_tween.is_valid():
		if Input.is_action_pressed("ui_accept"):
			scroll_tween.set_speed_scale(10.0)
		else:
			scroll_tween.set_speed_scale(1.0)
		
	if Input.is_action_just_pressed("ui_cancel"):
		return_to_main_menu()
	
	var particles = particle_effects.get_children()
	for particle in particles:
		if particle.emitting == false:
			particle.emitting = true

func move_credits() -> void:
	can_move = false
	var move_distance = -(get_viewport_rect().size.y + (c_box.size.y / 4))

	scroll_tween = create_tween()
	scroll_tween.tween_property(c_box, "position:y", move_distance, 62)
	scroll_tween.finished.connect(fade_credits)

func return_to_main_menu() -> void:
	AudioManager.stop(credits_music)
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func fade_credits() -> void:
	var tween = create_tween()
	tween.tween_property(center_container, "modulate:a", 0, 2)
	await tween.finished
	return_to_main_menu()
