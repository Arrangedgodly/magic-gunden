extends Node2D
class_name ScoreManager

var saved_game = SavedGame.new()
var current_killstreak: int = 0
var scores_to_update: Array

@onready var game_manager: GameManager = %GameManager
@onready var enemy_manager: EnemyManager = %EnemyManager
@onready var time_counter: Timer = $TimeCounter
@onready var player: Player = %Player

signal game_ended(final_saved_game: SavedGame)
signal new_highscore(new_score: int)
signal new_high_killcount(new_killcount: int)
signal new_high_time_alive(new_time_alive: int)
signal new_high_gems_captured(new_gems_captured: int)
signal new_high_killstreak(new_killstreak: int)
signal new_killstreak(new_killstreak_count: int)
signal update_score(new_score: int)

func _ready() -> void:
	game_manager.game_ended.connect(_on_game_manager_game_ended)
	time_counter.timeout.connect(_on_time_counter_timeout)

func _process(_delta: float) -> void:
	if len(scores_to_update) != 0:
		var score_to_add: int = 0
		for score_item in scores_to_update:
			score_to_add += score_item
		scores_to_update.clear()
		var score = saved_game.increase_score(score_to_add)
		update_score.emit(score)

func _on_time_counter_timeout() -> void:
	saved_game.increase_time_alive(1)
	time_counter.start()

func _on_game_manager_game_ended() -> void:
	game_ended.emit(saved_game)

func append_scores_to_add(new_score: int) -> void:
	scores_to_update.append(new_score)

func increase_kill_count():
	saved_game.increase_slimes_killed(1)
	increase_current_killstreak(1)
	append_scores_to_add(10 * current_killstreak)
	player.create_score_popup(10 * current_killstreak)

func increase_current_killstreak(killstreak_to_add: int) -> void:
	current_killstreak += killstreak_to_add
	
	new_killstreak.emit(current_killstreak)
	
	if current_killstreak > saved_game.killstreak:
		saved_game.set_killstreak(current_killstreak)

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
	
	if not high_scores.killstreak == null:
		if saved_game.killstreak > high_scores.killstreak:
			high_scores.set_killstreak(saved_game.killstreak)
			new_high_killstreak.emit(saved_game.killstreak)
	else:
		high_scores.set_killstreak(saved_game.killstreak)
		new_high_killstreak.emit(saved_game.killstreak)
		
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
