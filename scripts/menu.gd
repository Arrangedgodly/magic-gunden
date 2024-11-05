extends Control
@onready var v_box_container: VBoxContainer = $VBoxContainer
var animation_speed = 250
var move_direction = Vector2(1, 0)
@onready var start: Button = $VBoxContainer/Start
@onready var high_score: Button = $VBoxContainer/HighScore
@onready var credits_button: Button = $VBoxContainer/Credits
@onready var quit: Button = $VBoxContainer/Quit

@export var menu_music: AudioStream

func _ready() -> void:
	start.grab_focus()
	AudioManager.play_music(menu_music)

func _process(delta: float) -> void:
	v_box_container.position += move_direction * animation_speed * delta

func _on_start_pressed() -> void:
	AudioManager.stop(menu_music)
	get_tree().change_scene_to_file("res://scenes/magic_garden.tscn")

func _on_options_pressed() -> void:
	pass # Replace with function body.

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_credits_pressed() -> void:
	AudioManager.stop(menu_music)
	LoadManager.load_scene("res://scenes/credits.tscn")

func _on_high_score_pressed() -> void:
	AudioManager.stop(menu_music)
	get_tree().change_scene_to_file("res://scenes/high_score.tscn")

func _on_start_focus_entered() -> void:
	start.get_material().set_shader_parameter("speed", 2)

func _on_start_focus_exited() -> void:
	start.get_material().set_shader_parameter("speed", 0)

func _on_high_score_focus_entered() -> void:
	high_score.get_material().set_shader_parameter("speed", 2)

func _on_high_score_focus_exited() -> void:
	high_score.get_material().set_shader_parameter("speed", 0)

func _on_credits_focus_entered() -> void:
	credits_button.get_material().set_shader_parameter("speed", 2)

func _on_credits_focus_exited() -> void:
	credits_button.get_material().set_shader_parameter("speed", 0)

func _on_quit_focus_entered() -> void:
	quit.get_material().set_shader_parameter("speed", 2)

func _on_quit_focus_exited() -> void:
	quit.get_material().set_shader_parameter("speed", 0)
