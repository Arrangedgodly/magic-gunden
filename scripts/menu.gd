extends Control
@onready var start: Button = $VBoxContainer/Start
@onready var high_score: Button = $VBoxContainer/HighScore
@onready var options: Button = $VBoxContainer/Options
@onready var credits_button: Button = $VBoxContainer/Credits
@onready var quit: Button = $VBoxContainer/Quit

@export var menu_music: AudioStream

func _ready() -> void:
	start.pressed.connect(_on_start_pressed)
	start.focus_entered.connect(_on_start_focus_entered)
	start.focus_exited.connect(_on_start_focus_exited)
	high_score.pressed.connect(_on_high_score_pressed)
	high_score.focus_entered.connect(_on_high_score_focus_entered)
	high_score.focus_exited.connect(_on_high_score_focus_exited)
	options.pressed.connect(_on_options_pressed)
	options.focus_entered.connect(_on_options_focus_entered)
	options.focus_exited.connect(_on_options_focus_exited)
	credits_button.pressed.connect(_on_credits_pressed)
	credits_button.focus_entered.connect(_on_credits_focus_entered)
	credits_button.focus_exited.connect(_on_credits_focus_exited)
	quit.pressed.connect(_on_quit_pressed)
	quit.focus_entered.connect(_on_quit_focus_entered)
	quit.focus_exited.connect(_on_quit_focus_exited)
	
	start.grab_focus()
	AudioManager.play_music(menu_music)

func _on_start_pressed() -> void:
	AudioManager.stop(menu_music)
	get_tree().change_scene_to_file("res://scenes/magic_garden.tscn")

func _on_options_pressed() -> void:
	AudioManager.stop(menu_music)
	get_tree().change_scene_to_file("res://scenes/options.tscn")

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

func _on_options_focus_entered() -> void:
	options.get_material().set_shader_parameter("speed", 2)

func _on_options_focus_exited() -> void:
	options.get_material().set_shader_parameter("speed", 0)

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
