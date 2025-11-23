extends Control

@onready var score_banner: Sprite2D = $ScoreBanner
@onready var score_label: Label = $Score
@onready var controls: Control = $Controls
@onready var ammo_bar: Control = $AmmoBar
@onready var ammo_label: Label = $AmmoLabel
@onready var clip_count_label: Label = $"Clip Count"
@onready var current_killstreak_label: Label = $Current_Killstreak_Label
@onready var current_killstreak: Label = $Current_Killstreak
@onready var powerup_container: HBoxContainer = $PowerupContainer
@onready var game_manager: Node2D = $"../../GameManager"

var powerup_widget_scene = preload("res://scenes/powerup_widget.tscn")
var powerup_icons = {
	"Ricochet" = preload("res://assets/items/ricochet.png"),
	"Pierce" = preload("res://assets/items/pierce.png"),
	"Magnet" = preload("res://assets/items/magnet.png"),
	"Stomp" = preload("res://assets/items/stomp.png")
}
var active_widgets: Dictionary = {}
var current_display_score: int = 0
var current_ammo: int = 0
var player
var powerup_manager: PowerupManager

func _ready() -> void:
	current_killstreak_label.hide()
	current_killstreak.hide()
	
	powerup_manager = get_node("/root/MagicGarden/PowerupManager")
	powerup_manager.powerup_activated.connect(_on_powerup_activated)
	
	game_manager.update_score.connect(_on_game_manager_update_score)
	game_manager.ui_visible.connect(_on_game_manager_ui_visible)
	game_manager.current_ammo.connect(_on_game_manager_current_ammo)
	game_manager.killstreak.connect(_on_game_manager_killstreak)
	
func _input(event: InputEvent) -> void:
	controls.handle_input_event(event)

func _process(_delta: float) -> void:
	pass

func no_ammo_animation():
	var tween = create_tween()
	tween.tween_property(clip_count_label, "theme_override_colors/font_color", Color(5, 0, 0, 1), .125)
	tween.tween_property(clip_count_label, "theme_override_colors/font_color", Color(1, 1, 1, 1), .125)
	tween.tween_property(clip_count_label, "theme_override_colors/font_color", Color(5, 0, 0, 1), .125)
	tween.tween_property(clip_count_label, "theme_override_colors/font_color", Color(1, 1, 1, 1), .125)

func update_ammo_ui(ammo_count: int):
	if current_ammo != ammo_count:
		if ammo_count == 0:
			clip_count_label.text = "no clips!"
		elif ammo_count <= 6:
			clip_count_label.text = "last clip!"
		else:
			clip_count_label.text = str(ammo_count / 6) + "clips!"
	

func _on_tutorial_tutorial_finished() -> void:
	controls.show()
	ammo_bar.show()
	clip_count_label.show()
	ammo_label.show()
	score_banner.show()
	score_label.show()

func _on_game_manager_update_score(new_score: int) -> void:
	var start_score = current_display_score
	var score_difference = new_score - start_score
	var steps = 10
	var step_duration = .5 / steps
	
	for i in range(steps):
		var step_score = start_score + (score_difference * (i + 1) / steps)
		score_label.text = str(round(step_score)).pad_zeros(5)
		await get_tree().create_timer(step_duration).timeout
	
	current_display_score = new_score
	score_label.text = str(current_display_score).pad_zeros(5)

func _on_game_manager_ui_visible(is_ui_visible: bool) -> void:
	self.visible = is_ui_visible

func _on_game_manager_killstreak(new_killstreak: int) -> void:
	if new_killstreak > 0:
		current_killstreak_label.show()
		current_killstreak.show()
		current_killstreak.text = str(new_killstreak)
	else:
		current_killstreak_label.hide()
		current_killstreak.hide()

func _on_game_manager_current_ammo(new_ammo: int) -> void:
	if new_ammo == 0:
		no_ammo_animation()
	
	current_ammo = new_ammo
	update_ammo_ui(new_ammo)

func _on_powerup_activated(p_name: String) -> void:
	if active_widgets.has(p_name):
		return

	var timer_node = powerup_manager.get_powerup_timer(p_name)
	
	if not timer_node:
		push_error("UI: No timer found for " + p_name)
		return

	var new_widget = powerup_widget_scene.instantiate()
	powerup_container.add_child(new_widget)
	
	var icon = powerup_icons.get(p_name)
	
	new_widget.setup(p_name, timer_node, icon)
	
	active_widgets[p_name] = new_widget
	
	new_widget.tree_exiting.connect(func(): active_widgets.erase(p_name))
