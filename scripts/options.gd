extends Control

@onready var music_slider: HSlider = %MusicSlider
@onready var sfx_slider: HSlider = %SFXSlider
@onready var music_value_label: Label = %MusicValueLabel
@onready var sfx_value_label: Label = %SFXValueLabel
@onready var reset_save_button: Button = %ResetSaveButton
@onready var reset_tutorial_button: Button = %ResetTutorialButton
@onready var reset_all_button: Button = %ResetAllButton
@onready var confirmation_popup: Control = %"Confirmation Popup"
@onready var controls_button: Button = %ControlsButton
@onready var back_button: Button = %BackButton
@onready var margin_container: MarginContainer = $MarginContainer

@export var options_music: AudioStream
@export var controls_music: AudioStream

var settings_save: SettingsSave

signal options_closed

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	load_settings()
	confirmation_popup.hide()
	
	setup_volume_controls()
	
	reset_save_button.pressed.connect(_on_reset_save_pressed)
	reset_tutorial_button.pressed.connect(_on_reset_tutorial_pressed)
	reset_all_button.pressed.connect(_on_reset_all_pressed)
	controls_button.pressed.connect(_on_controls_pressed)
	back_button.pressed.connect(_on_back_pressed)
	back_button.grab_focus()
	
	AudioManager.play_music(options_music)

func load_settings() -> void:
	settings_save = load("user://settings.tres") as SettingsSave
	if settings_save == null:
		settings_save = SettingsSave.new()
		save_settings()

func save_settings() -> void:
	ResourceSaver.save(settings_save, "user://settings.tres")

func setup_volume_controls() -> void:
	music_slider.min_value = 0
	music_slider.max_value = 100
	music_slider.step = 1
	music_slider.value = settings_save.music_volume
	
	sfx_slider.min_value = 0
	sfx_slider.max_value = 100
	sfx_slider.step = 1
	sfx_slider.value = settings_save.sfx_volume
	
	music_slider.value_changed.connect(_on_music_volume_changed)
	sfx_slider.value_changed.connect(_on_sfx_volume_changed)
	
	apply_volume_settings()
	update_volume_labels()

func apply_volume_settings() -> void:
	var music_db = linear_to_db(settings_save.music_volume / 100.0)
	var sfx_db = linear_to_db(settings_save.sfx_volume / 100.0)
	
	var music_bus_idx = AudioServer.get_bus_index("Music")
	var sfx_bus_idx = AudioServer.get_bus_index("SFX")
	
	if music_bus_idx >= 0:
		AudioServer.set_bus_volume_db(music_bus_idx, music_db)
	
	if sfx_bus_idx >= 0:
		AudioServer.set_bus_volume_db(sfx_bus_idx, sfx_db)

func update_volume_labels() -> void:
	music_value_label.text = str(int(music_slider.value)) + "%"
	sfx_value_label.text = str(int(sfx_slider.value)) + "%"

func _on_music_volume_changed(value: float) -> void:
	settings_save.music_volume = value
	apply_volume_settings()
	update_volume_labels()
	save_settings()

func _on_sfx_volume_changed(value: float) -> void:
	settings_save.sfx_volume = value
	apply_volume_settings()
	update_volume_labels()
	save_settings()

func linear_to_db(linear: float) -> float:
	if linear <= 0:
		return -80.0
	return 20.0 * log(linear) / log(10.0)

func _on_reset_save_pressed() -> void:
	show_confirmation("Are you sure you want to reset your game save data?\nThis will delete your high scores and progress!", 
		func(): reset_game_save())

func _on_reset_tutorial_pressed() -> void:
	show_confirmation("Are you sure you want to reset the tutorial?\nYou will see it again next time you play.", 
		func(): reset_tutorial_save())

func _on_reset_all_pressed() -> void:
	show_confirmation("Are you sure you want to reset ALL data?\nThis will delete everything including settings!", 
		func(): reset_all_data())

func show_confirmation(message: String, callback: Callable) -> void:
	if confirmation_popup:
		confirmation_popup.set_warning_text(message)
		confirmation_popup.show()
		confirmation_popup.enable_focus()
		
		if confirmation_popup.confirmation.is_connected(_on_confirmation_received):
			confirmation_popup.confirmation.disconnect(_on_confirmation_received)
		
		confirmation_popup.confirmation.connect(_on_confirmation_received.bind(callback), CONNECT_ONE_SHOT)

func _on_confirmation_received(confirmed: bool, callback: Callable) -> void:
	if confirmed:
		callback.call()
	
	confirmation_popup.hide()
	back_button.grab_focus()

func reset_game_save() -> void:
	var save_path = "user://save.tres"
	if FileAccess.file_exists(save_path):
		DirAccess.remove_absolute(save_path)

func reset_tutorial_save() -> void:
	var tutorial_path = "user://tutorial.tres"
	var tutorial_save = TutorialSave.new()
	tutorial_save.show_tutorial = true
	tutorial_save.has_played = false
	ResourceSaver.save(tutorial_save, tutorial_path)

func reset_all_data() -> void:
	reset_game_save()
	reset_tutorial_save()
	
	settings_save = SettingsSave.new()
	save_settings()
	
	setup_volume_controls()

func _on_controls_pressed() -> void:
	var controls_scene = load("res://scenes/controls_menu.tscn")
	var controls_instance = controls_scene.instantiate()
	add_child(controls_instance)
		
	controls_instance.controls_closed.connect(_on_controls_closed)
	margin_container.hide()
	
	AudioManager.stop(options_music)
	AudioManager.play_music(controls_music)

func _on_controls_closed() -> void:
	margin_container.show()
	back_button.grab_focus()
	
	AudioManager.stop(controls_music)
	AudioManager.play_music(options_music)

func _on_back_pressed() -> void:
	options_closed.emit()
	AudioManager.stop(options_music)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_on_back_pressed()
