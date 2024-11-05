extends Control

@onready var c_box: VBoxContainer = $CenterContainer/VBoxContainer
@onready var center_container: Control = $CenterContainer
@onready var particle_effects: Node2D = $"CenterContainer/Particle Effects"

@export var credits_music: AudioStream

var credits = []
var can_move : bool = false

func _ready() -> void:
	AudioManager.play_music(credits_music)
	credits = c_box.get_children()
	credits.sort_custom(_sort_text)
	c_box.position.y += get_viewport_rect().size.y
	for node in credits:
		c_box.remove_child(node)
	
	for credit in credits:
		c_box.add_child(credit)
		
	can_move = true
	
func _process(_delta: float) -> void:
	if can_move:
		move_credits()
		
	if Input.is_action_just_pressed("ui_cancel"):
		return_to_main_menu()
	
	var particles = particle_effects.get_children()
	for particle in particles:
		if particle.emitting == false:
			particle.emitting = true

func _sort_text(a, b) -> bool:
	return a.text < b.text

func move_credits() -> void:
	can_move = false
	var move_distance = -(get_viewport_rect().size.y + (c_box.size.y / 4))

	var tween = create_tween()
	tween.tween_property(c_box, "position:y", move_distance, 62)
	tween.finished.connect(fade_credits)

func return_to_main_menu() -> void:
	AudioManager.stop(credits_music)
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func fade_credits() -> void:
	var tween = create_tween()
	tween.tween_property(center_container, "modulate:a", 0, 2)
	await tween.finished
	return_to_main_menu()
