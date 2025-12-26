extends Control
@onready var yes: Button = %Yes
@onready var no: Button = %No
@onready var ui: CanvasLayer = %UI
@onready var flash_score: VBoxContainer = %FlashScore
@onready var scores: Control = %Scores
@onready var final_score: Label = %FinalScore
@onready var final_score_label: Label = %"Final Score Label"
@onready var final_killcount_label: Label = %"Final Killcount Label"
@onready var final_killcount: Label = %FinalKillcount
@onready var best_killstreak_label: Label = %BestKillstreakLabel
@onready var best_killstreak: Label = %BestKillstreak
@onready var time_alive_label: Label = %"Time Alive Label"
@onready var time_alive: Label = %"Time Alive"
@onready var gems_captured_label: Label = %"Gems Captured Label"
@onready var gems_captured: Label = %"Gems Captured"
@onready var try_again: Label = %"Try Again?"
@onready var yes_no_container: HBoxContainer = %YesNoContainer
@onready var curve_shader = preload("res://shaders/curved_and_vertical_motion.gdshader")

var score_manager: ScoreManager
var try_again_sfx: AudioStream = preload("res://assets/sounds/sfx/Retro Ring 04.wav")
var high_score_sfx: AudioStream = preload("res://assets/sounds/sfx/Retro PowerUP 09.wav")

func _ready() -> void:
	score_manager = get_node("/root/MagicGarden/Systems/ScoreManager")
	
	if not score_manager.game_ended.is_connected(_on_score_manager_game_ended):
		score_manager.game_ended.connect(_on_score_manager_game_ended)
		
	if not score_manager.new_highscore.is_connected(_on_score_manager_new_highscore):
		score_manager.new_highscore.connect(_on_score_manager_new_highscore)
		
	if not score_manager.new_high_killcount.is_connected(_on_score_manager_new_high_killcount):
		score_manager.new_high_killcount.connect(_on_score_manager_new_high_killcount)
		
	if not score_manager.new_high_killstreak.is_connected(_on_score_manager_new_high_killstreak):
		score_manager.new_high_killstreak.connect(_on_score_manager_new_high_killstreak)
		
	if not score_manager.new_high_gems_captured.is_connected(_on_score_manager_new_high_gems_captured):
		score_manager.new_high_gems_captured.connect(_on_score_manager_new_high_gems_captured)
		
	if not score_manager.new_high_time_alive.is_connected(_on_score_manager_new_high_time_alive):
		score_manager.new_high_time_alive.connect(_on_score_manager_new_high_time_alive)
	
	if not flash_score.animation_finished.is_connected(_on_flash_score_animation_finished):
		flash_score.animation_finished.connect(_on_flash_score_animation_finished)
		
	hide()
	
func _on_score_manager_game_ended(final_saved_game) -> void:
	final_score.text = str(final_saved_game.score)
	final_killcount.text = str(final_saved_game.slimes_killed)
	best_killstreak.text = str(final_saved_game.killstreak)
	time_alive.text = final_saved_game.get_time_alive_in_minutes()
	gems_captured.text = str(final_saved_game.gems_captured)
	show()
	ui.hide()

func _on_no_pressed() -> void:
	hide()
	get_tree().change_scene_to_file("res://scenes/menus/main_menu.tscn")

func _on_yes_pressed() -> void:
	hide()
	get_tree().change_scene_to_file("res://scenes/magic_garden.tscn")

func _on_score_manager_new_highscore() -> void:
	await flash_score.animation_finished
	final_score_label.text = "NEW BEST HIGH SCORE"
	_set_shader(final_score_label)
	_set_shader(final_score)
	AudioManager.play_sound(high_score_sfx)

func _on_score_manager_new_high_killcount() -> void:
	await flash_score.animation_finished
	final_killcount_label.text = "NEW TOP KILL COUNT"
	_set_shader(final_killcount_label)
	_set_shader(final_killcount)
	AudioManager.play_sound(high_score_sfx)

func _on_score_manager_new_high_killstreak() -> void:
	await flash_score.animation_finished
	best_killstreak_label.text = "NEW BEST KILLSTREAK"
	_set_shader(best_killstreak_label)
	_set_shader(best_killstreak)
	AudioManager.play_sound(high_score_sfx)

func _on_score_manager_new_high_time_alive() -> void:
	await flash_score.animation_finished
	time_alive_label.text = "NEW LONGEST TIME ALIVE"
	_set_shader(time_alive_label)
	_set_shader(time_alive)
	AudioManager.play_sound(high_score_sfx)

func _on_score_manager_new_high_gems_captured() -> void:
	await flash_score.animation_finished
	gems_captured_label.text = "NEW TOP GEMS CAPTURED"
	_set_shader(gems_captured_label)
	_set_shader(gems_captured)
	AudioManager.play_sound(high_score_sfx)

func _on_flash_score_animation_finished() -> void:
	AudioManager.play_sound(try_again_sfx)
	try_again.show()
	yes_no_container.show()
	yes.grab_focus()

func _set_shader(target_label: Label) -> void:
	var new_material = ShaderMaterial.new()
	new_material.shader = curve_shader
	target_label.material = new_material
	target_label.material.set_shader_parameter("wave_amplitude", 30.0)
	target_label.material.set_shader_parameter("wave_frequency", 75.0)
	target_label.material.set_shader_parameter("movement_speed", 3.0)
	target_label.material.set_shader_parameter("movement_amplitude", 8.0)
