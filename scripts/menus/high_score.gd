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
@onready var exit_button: Button = %Exit

@export var high_score_music: AudioStream

func _ready() -> void:
	AudioManager.play_music(high_score_music)
	scores.hide()
	no_scores.hide()
	saved_game = SaveHelper.load_high_scores()
	
	exit_button.pressed.connect(exit)
	
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
	if Input.is_action_just_pressed("ui_cancel"):
		exit()

func exit() -> void:
	AudioManager.stop(high_score_music)
	LoadManager.quick_load("res://scenes/menus/main_menu.tscn")
