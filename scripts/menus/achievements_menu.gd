extends Control

@onready var grid: GridContainer = %Grid
@onready var icon_preview: TextureRect = %IconPreview
@onready var title_label: Label = %Title
@onready var desc_label: RichTextLabel = %Description
@onready var progress_bar: ProgressBar = %ProgressBar
@onready var progress_text: Label = %ProgressLabel
@onready var exit_button: Button = %Exit

var icon_scene = preload("res://scenes/ui/achievement_icon.tscn")
var hidden_icon = preload("res://assets/achievements/questionmark.png")
var achievement_music: AudioStream = preload("res://assets/sounds/music/Gnomal Festivities.wav")

var unknown_title: String = "???"
var unknown_desc: String = "This achievement is hidden until unlocked."

func _ready() -> void:
	AudioManager.play_music(achievement_music)
	_clear_info()
	_populate_grid()
	
	exit_button.pressed.connect(exit)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		exit()

func exit() -> void:
	set_process(false)
	AudioManager.stop(achievement_music)
	LoadManager.quick_load("res://scenes/menus/main_menu.tscn")

func _populate_grid() -> void:
	for child in grid.get_children():
		child.queue_free()
	
	var all_achievements = AchievementManager.achievements.values()
	
	all_achievements.sort_custom(func(a, b): return a.id < b.id)
	
	for data in all_achievements:
		var icon_instance = icon_scene.instantiate()
		grid.add_child(icon_instance)
		
		icon_instance.setup(data)
		icon_instance.hovered.connect(_on_icon_hovered)
		icon_instance.unhovered.connect(_on_icon_unhovered)

func _on_icon_hovered(data: AchievementData) -> void:
	if not is_inside_tree(): 
		return
		
	if data.hidden and not data.is_unlocked:
		title_label.text = unknown_title
		desc_label.text = unknown_desc
		icon_preview.texture = hidden_icon
		progress_bar.hide()
		_set_preview_shader(false)
	else:
		title_label.text = data.title
		desc_label.text = data.description
		icon_preview.texture = data.icon
		_set_preview_shader(not data.is_unlocked)
		
		if data.icon == null:
			icon_preview.texture = hidden_icon
			_set_preview_shader(false)
		
		if data.is_unlocked:
			progress_bar.value = 100
			progress_text.text = "Completed"
		else:
			progress_bar.show()
			progress_bar.max_value = data.goal
			progress_bar.value = data.current_progress
			progress_text.text = "%d / %d" % [data.current_progress, data.goal]

func _on_icon_unhovered() -> void:
	if not is_inside_tree(): 
		return
		
	_clear_info()

func _clear_info() -> void:
	title_label.text = "Select an Achievement"
	desc_label.text = ""
	icon_preview.texture = null
	progress_bar.hide()
	_set_preview_shader(false)

func _set_preview_shader(is_locked: bool) -> void:
	if not is_instance_valid(icon_preview):
		return
		
	icon_preview.material.set_shader_parameter("is_locked", is_locked)
