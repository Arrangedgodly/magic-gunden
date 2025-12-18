extends Control
var saved_game:SavedGame
@onready var scores: VBoxContainer = $CenterContainer/Scores
@onready var high_score: Label = $"CenterContainer/Scores/VBoxContainer/High Score"
@onready var most_kills: Label = $"CenterContainer/Scores/VBoxContainer2/Most Kills"
@onready var time_alive: Label = $"CenterContainer/Scores/VBoxContainer3/Time Alive"
@onready var gems_captured: Label = $"CenterContainer/Scores/VBoxContainer4/Gems Captured"
@onready var no_scores: Label = $"CenterContainer/No Scores"
@onready var center_container: CenterContainer = $CenterContainer
@onready var crt: ColorRect = $CRT

@export var high_score_music: AudioStream

func _ready() -> void:
	AudioManager.play_music(high_score_music)
	scores.hide()
	no_scores.hide()
	var saved_game_path = "user://save.tres"
	if FileAccess.file_exists(saved_game_path):
		saved_game = load(saved_game_path) as SavedGame
	if saved_game == null:
		no_scores.show()
	else:
		scores.show()
		high_score.text = str(saved_game.score)
		most_kills.text = str(saved_game.slimes_killed)
		time_alive.text = convert_time_to_minutes(saved_game.time_alive)
		gems_captured.text = str(saved_game.gems_captured)

func _process(_delta: float) -> void:
	center_container.position.x += .25
	crt.position.x += .25
	if Input.is_action_just_pressed("ui_cancel"):
		AudioManager.stop(high_score_music)
		get_tree().change_scene_to_file("res://scenes/menus/main_menu.tscn")

func convert_time_to_minutes(seconds: int):
	@warning_ignore("integer_division")
	var minutes = seconds / 60
	var leftover_seconds = seconds % 60
	var seconds_string
	if leftover_seconds < 10:
		seconds_string = "0" + str(leftover_seconds)
	else:
		seconds_string = str(leftover_seconds)
	var time_string = str(minutes) + ":" + seconds_string
	return time_string
