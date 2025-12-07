extends Node2D

var game_paused : bool
@onready var resume: Button = $HBoxContainer/Resume
@onready var restart: Button = $HBoxContainer/Restart
@onready var options: Button = $HBoxContainer/Options
@onready var main_menu: Button = $HBoxContainer/MainMenu
@onready var quit: Button = $HBoxContainer/Quit
@onready var restart_warning: Control = $RestartWarning
@onready var quit_warning: Control = $QuitWarning
@onready var background: Sprite2D = $Sprite2D
@onready var paused_label: Label = $PAUSED
@onready var h_box: HBoxContainer = $HBoxContainer
@onready var dev_console: Control

signal main_menu_pressed

func _ready():
	var reset_warning_text = "Are you sure you would like to restart the game? This will delete your current progress!"
	restart_warning.set_warning_text(reset_warning_text)
	
	var quit_warning_text = "Are you sure you would like to quit? The game will exit unsaved!"
	quit_warning.set_warning_text(quit_warning_text)
	
	resume.pressed.connect(_on_resume_pressed)
	restart.pressed.connect(_on_restart_pressed)
	options.pressed.connect(_on_options_pressed)
	main_menu.pressed.connect(_on_main_menu_pressed)
	quit.pressed.connect(_on_quit_pressed)
	
	dev_console = get_node("/root/MagicGarden/HUD/DevConsole")
	dev_console.console_opened.connect(_on_dev_console_console_opened)
	
	enable_focus()
	
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("menu"):
		if game_paused:
			unpause_game()
		else:
			restart_warning.visible = false
			quit_warning.visible = false
			game_paused = true
			get_tree().paused = true
			self.visible = true
			enable_focus()

func _on_resume_pressed() -> void:
	unpause_game()

func _on_restart_pressed() -> void:
	restart_warning.visible = true
	restart_warning.enable_focus()

func _on_restart_warning_confirmation(confirmation: bool) -> void:
	if confirmation:
		unpause_game()
		get_tree().change_scene_to_file("res://scenes/magic_garden.tscn")
	else:
		remove_child(restart_warning)
		enable_focus()

func _on_options_pressed() -> void:
	var options_scene = load("res://scenes/options.tscn")
	var options_instance = options_scene.instantiate()
	add_child(options_instance)
	options_instance.options_closed.connect(_on_options_closed.bind(options_instance))
	background.hide()
	paused_label.hide()
	h_box.hide()

func _on_main_menu_pressed() -> void:
	main_menu_pressed.emit()
	unpause_game()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_quit_pressed() -> void:
	quit_warning.visible = true
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

func _on_options_closed(options_instance: Control) -> void:
	options_instance.queue_free()
	background.show()
	paused_label.show()
	h_box.show()
	enable_focus()

func _on_dev_console_console_opened(is_open: bool) -> void:
	if is_open:
		process_mode = Node.PROCESS_MODE_DISABLED
	else:
		process_mode = Node.PROCESS_MODE_ALWAYS
