extends Node2D

var game_paused : bool
@onready var resume: Button = $HBoxContainer/Resume
@onready var restart: Button = $HBoxContainer/Restart
@onready var main_menu: Button = $HBoxContainer/MainMenu
@onready var quit: Button = $HBoxContainer/Quit
@onready var restart_warning: Control = $RestartWarning
@onready var quit_warning: Control = $QuitWarning

func _ready():
	var reset_warning_text = "Are you sure you would like to restart the game? This will delete your current progress!"
	restart_warning.set_warning_text(reset_warning_text)
	
	var quit_warning_text = "Are you sure you would like to quit? The game will exit unsaved!"
	quit_warning.set_warning_text(quit_warning_text)
	
	enable_focus()
	
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("menu"):
		if game_paused:
			unpause_game()
		else:
			remove_child(restart_warning)
			remove_child(quit_warning)
			game_paused = true
			get_tree().paused = true
			self.visible = true
			enable_focus()

func _on_resume_pressed() -> void:
	unpause_game()

func _on_restart_pressed() -> void:
	add_child(restart_warning)
	restart_warning.enable_focus()

func _on_restart_warning_confirmation(confirmation: bool) -> void:
	if confirmation:
		unpause_game()
		get_tree().change_scene_to_file("res://scenes/magic_garden.tscn")
	else:
		remove_child(restart_warning)
		enable_focus()

func _on_main_menu_pressed() -> void:
	unpause_game()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_quit_pressed() -> void:
	add_child(quit_warning)
	quit_warning.enable_focus()
	
func _on_quit_warning_confirmation(confirmation: bool) -> void:
	if confirmation:
		get_tree().quit()
	else:
		remove_child(quit_warning)
		enable_focus()

func unpause_game():
	game_paused = false
	get_tree().paused = false
	self.visible = false

func enable_focus():
	resume.grab_focus()

func _on_resume_focus_entered() -> void:
	resume.get_material().set_shader_parameter("speed", 2)

func _on_resume_focus_exited() -> void:
	resume.get_material().set_shader_parameter("speed", 0)

func _on_restart_focus_entered() -> void:
	restart.get_material().set_shader_parameter("speed", 2)

func _on_restart_focus_exited() -> void:
	restart.get_material().set_shader_parameter("speed", 0)

func _on_main_menu_focus_entered() -> void:
	main_menu.get_material().set_shader_parameter("speed", 2)

func _on_main_menu_focus_exited() -> void:
	main_menu.get_material().set_shader_parameter("speed", 0)

func _on_quit_focus_entered() -> void:
	quit.get_material().set_shader_parameter("speed", 2)

func _on_quit_focus_exited() -> void:
	quit.get_material().set_shader_parameter("speed", 0)
