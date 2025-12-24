extends Control
@onready var start: Button = $VBoxContainer/Start
@onready var high_score: Button = $VBoxContainer/HighScore
@onready var options: Button = $VBoxContainer/Options
@onready var credits_button: Button = $VBoxContainer/Credits
@onready var quit: Button = $VBoxContainer/Quit
@onready var v_box: VBoxContainer = $VBoxContainer
@onready var background: ParallaxBackground = $MainMenuBackground
@export var menu_music: AudioStream

func _ready() -> void:
	DebugLogger.log_info("=== MAIN MENU READY START ===")
	DebugLogger.log_info("Platform: " + ("Web" if OS.has_feature("web") else "Desktop"))
	
	start.pressed.connect(_on_start_pressed)
	high_score.pressed.connect(_on_high_score_pressed)
	options.pressed.connect(_on_options_pressed)
	credits_button.pressed.connect(_on_credits_pressed)
	quit.pressed.connect(_on_quit_pressed)
	
	start.grab_focus()
	
	DebugLogger.log_info("Playing menu music...")
	AudioManager.play_music(menu_music)
	
	DebugLogger.log_info("=== MAIN MENU READY COMPLETE ===")

func _on_start_pressed() -> void:
	DebugLogger.log_info("=== START BUTTON PRESSED ===")
	AudioManager.stop(menu_music)
	DebugLogger.log_info("Attempting to change scene to magic_garden...")
	var result = get_tree().change_scene_to_file("res://scenes/magic_garden.tscn")
	
	if result != OK:
		DebugLogger.log_error("Scene change failed with error: " + str(result))
	else:
		DebugLogger.log_info("Scene change initiated successfully")

func _on_options_pressed() -> void:
	AudioManager.stop(menu_music)
	var options_scene = load("res://scenes/menus/options.tscn")
	var options_instance = options_scene.instantiate()
	add_child(options_instance)
	options_instance.options_closed.connect(_on_options_closed.bind(options_instance))
	background.hide()
	v_box.hide()

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_credits_pressed() -> void:
	AudioManager.stop(menu_music)
	LoadManager.load_scene("res://scenes/menus/credits.tscn")

func _on_high_score_pressed() -> void:
	AudioManager.stop(menu_music)
	get_tree().change_scene_to_file("res://scenes/menus/high_score.tscn")

func _on_options_closed(options_instance: Control) -> void:
	options_instance.queue_free()
	background.show()
	v_box.show()
	start.grab_focus()
	AudioManager.play_music(menu_music)
