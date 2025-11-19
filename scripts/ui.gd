extends Control

@onready var score_banner: Sprite2D = $ScoreBanner
@onready var score_label: Label = $Score
@onready var controls: Control = $Controls
@onready var ammo_bar: Control = $AmmoBar
@onready var ammo_label: Label = $AmmoLabel
@onready var clip_count_label: Label = $"Clip Count"
@onready var current_killstreak_label: Label = $Current_Killstreak_Label
@onready var current_killstreak: Label = $Current_Killstreak
@onready var powerup_timer_label: Label = $"Powerup Timer Label"
@onready var powerup_timer: Label = $"Powerup Timer"
@onready var score_timer: Timer = $ScoreTimer

var current_display_score: int = 0

func _ready() -> void:
	current_killstreak_label.hide()
	current_killstreak.hide()
	
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

func update_ammo_ui(ammo_count: int, clip_count: int):
	if clip_count == 0:
		if ammo_count == 0:
			clip_count_label.text = "no clips!"
		else:
			clip_count_label.text = "last clip!"
	else:
		clip_count_label.text = str(clip_count) + "clips!"

func update_score(target_score: int, duration: float) -> void:
	var start_score = current_display_score
	var score_difference = target_score - start_score
	var steps = 10
	var step_duration = duration / steps
	
	for i in range(steps):
		var step_score = start_score + (score_difference * (i + 1) / steps)
		score_label.text = str(round(step_score)).pad_zeros(5)
		await get_tree().create_timer(step_duration).timeout
	
	current_display_score = target_score
	score_label.text = str(current_display_score).pad_zeros(5)

func _on_tutorial_tutorial_finished() -> void:
	controls.show()
	ammo_bar.show()
	clip_count_label.show()
	ammo_label.show()
	score_banner.show()
	score_label.show()

func update_killstreak(count: int):
	if count > 0:
		current_killstreak_label.show()
		current_killstreak.show()
		current_killstreak.text = str(count)
	else:
		current_killstreak_label.hide()
		current_killstreak.hide()

func toggle_game_ui(is_visible: bool):
	visible = is_visible
