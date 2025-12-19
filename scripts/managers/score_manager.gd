extends Node2D
class_name ScoreManager

var saved_game = SavedGame.new()
var current_killstreak: int = 0
var top_killstreak: int = 0

@onready var game_manager: GameManager = %GameManager
@onready var enemy_manager: EnemyManager = %EnemyManager

signal game_ended(final_score: int, kill_count: int, time_alive: int, gems_captured: int)
signal new_highscore(new_score: int)
signal new_high_killcount(new_killcount: int)
signal new_high_time_alive(new_time_alive: int)
signal new_high_gems_captured(new_gems_captured: int)
signal new_high_killstreak(new_killstreak: int)
signal new_killstreak(new_killstreak_count: int)

func _ready() -> void:
	game_manager.game_ended.connect(_on_game_manager_game_ended)

func _on_game_manager_game_ended() -> void:
	game_ended.emit(saved_game.score, saved_game.slimes_killed, saved_game.time_alive, saved_game.gems_captured)

func increase_current_killstreak(killstreak_to_add: int) -> void:
	current_killstreak += killstreak_to_add
	
	new_killstreak.emit(current_killstreak)
	
	if current_killstreak > top_killstreak:
		top_killstreak = current_killstreak

func reset_current_killstreak() -> void:
	current_killstreak = 0
	new_killstreak.emit(0)

func save_game():
	var high_scores_path = "user://save.tres"
	var high_scores: SavedGame
	
	if FileAccess.file_exists(high_scores_path):
		high_scores = load(high_scores_path)
	
	if high_scores == null:
		high_scores = SavedGame.new()
		
	if not high_scores.score == null:
		if saved_game.score > high_scores.score:
			high_scores.set_score(saved_game.score)
			new_highscore.emit(saved_game.score)
	else:
		new_highscore.emit(saved_game.score)
	
	if not high_scores.slimes_killed == null:
		if saved_game.slimes_killed > high_scores.slimes_killed:
			high_scores.set_slimes_killed(saved_game.slimes_killed)
			new_high_killcount.emit(saved_game.slimes_killed)
	else:
		high_scores.set_slimes_killed(saved_game.slimes_killed)
		new_high_killcount.emit(saved_game.slimes_killed)
		
	if not high_scores.time_alive == null:
		if saved_game.time_alive > high_scores.time_alive:
			high_scores.set_time_alive(saved_game.time_alive)
			new_high_time_alive.emit(saved_game.time_alive)
	else:
		high_scores.set_time_alive(saved_game.time_alive)
		new_high_time_alive.emit(saved_game.time_alive)
		
	if not high_scores.gems_captured == null:
		if saved_game.gems_captured > high_scores.gems_captured:
			high_scores.set_gems_captured(saved_game.gems_captured)
			new_high_gems_captured.emit(saved_game.gems_captured)
	else:
		high_scores.set_gems_captured(saved_game.gems_captured)
		new_high_gems_captured.emit(saved_game.gems_captured)
	
	if not high_scores.killstreak == null:
		if saved_game.killstreak > high_scores.killstreak:
			high_scores.set_killstreak(saved_game.killstreak)
			new_high_killstreak.emit(saved_game.killstreak)
	
	else:
		high_scores.set_killstreak(saved_game.killstreak)
		new_high_killstreak.emit(saved_game.killstreak)
	
	ResourceSaver.save(high_scores, "user://save.tres")
