extends Control

@onready var score_banner: Sprite2D = %ScoreBanner
@onready var score_label: Label = %ScoreLabel
@onready var controls: Control = $Controls
@onready var ammo_bar: Control = %AmmoBar
@onready var ammo_label: Label = %AmmoLabel
@onready var current_killstreak_label: Label = %Current_Killstreak_Label
@onready var current_killstreak: Label = %Current_Killstreak
@onready var powerup_container: HBoxContainer = $PowerupContainer
@onready var game_manager: Node2D = %GameManager

var current_display_score: int = 0
var current_ammo: int = 0
var player

func _ready() -> void:
	current_killstreak_label.hide()
	current_killstreak.hide()
	
	game_manager.update_score.connect(_on_game_manager_update_score)
	game_manager.ui_visible.connect(_on_game_manager_ui_visible)
	game_manager.current_ammo.connect(_on_game_manager_current_ammo)
	game_manager.killstreak.connect(_on_game_manager_killstreak)
	
func _input(event: InputEvent) -> void:
	controls.handle_input_event(event)
	
func _on_tutorial_tutorial_finished() -> void:
	controls.show()
	ammo_bar.show()
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
	current_ammo = new_ammo
