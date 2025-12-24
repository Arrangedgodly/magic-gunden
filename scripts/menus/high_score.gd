extends Control
var saved_game:SavedGame
@onready var scores: VBoxContainer = $CenterContainer/Scores
@onready var high_score: Label = %"High Score"
@onready var most_kills: Label = %"Most Kills"
@onready var best_killstreak: Label = %BestKillstreak
@onready var time_alive: Label = %"Time Alive"
@onready var gems_captured: Label = %"Gems Captured"
@onready var no_scores: Label = %"No Scores"
@onready var center_container: CenterContainer = $CenterContainer
@onready var crt: ColorRect = $CRT

@export var high_score_music: AudioStream

func _ready() -> void:
	AudioManager.play_music(high_score_music)
	scores.hide()
	no_scores.hide()
	var saved_game_path = "user://save.tres"
	var file_exists = false
	if OS.has_feature("web"):
		DebugLogger.log_info("Web build - skipping high score save file check")
	else:
		file_exists = FileAccess.file_exists(saved_game_path)
		DebugLogger.log_info("High score save exists: " + str(file_exists))
	
	if file_exists:
		saved_game = load(saved_game_path) as SavedGame
		DebugLogger.log_info("Loaded high score save")
	
	if saved_game == null:
		no_scores.show()
	else:
		scores.show()
		high_score.text = str(saved_game.score)
		most_kills.text = str(saved_game.slimes_killed)
		best_killstreak.text = str(saved_game.killstreak)
		time_alive.text = saved_game.get_time_alive_in_minutes()
		gems_captured.text = str(saved_game.gems_captured)

func _process(_delta: float) -> void:
	center_container.position.x += .25
	crt.position.x += .25
	if Input.is_action_just_pressed("ui_cancel"):
		AudioManager.stop(high_score_music)
		get_tree().change_scene_to_file("res://scenes/menus/main_menu.tscn")
