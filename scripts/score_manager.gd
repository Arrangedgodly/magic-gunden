extends Node2D

signal score_updated(new_score: int)
signal killstreak_changed(new_streak: int)

var score: int = 0
var kill_count: int = 0
var time_alive: int = 0
var gems_captured: int = 0
var scores_to_update: Array = []

func _process(_delta: float) -> void:
	if len(scores_to_update) != 0:
		var score_to_add: int = 0
		for score_item in scores_to_update:
			score_to_add += score_item
		scores_to_update.clear()
		score += score_to_add
		score_updated.emit(score)

func add_score(points: int) -> void:
	scores_to_update.append(points)

func increase_kill_count() -> void:
	kill_count += 1
	scores_to_update.append(10 * kill_count)
	killstreak_changed.emit(kill_count)

func reset_kill_count() -> void:
	kill_count = 0
	killstreak_changed.emit(kill_count)

func increment_time_alive() -> void:
	time_alive += 1

func increment_gems_captured() -> void:
	gems_captured += 1

func get_score() -> int:
	return score

func get_kill_count() -> int:
	return kill_count

func get_time_alive() -> int:
	return time_alive

func get_gems_captured() -> int:
	return gems_captured

func reset_all() -> void:
	score = 0
	kill_count = 0
	time_alive = 0
	gems_captured = 0
	scores_to_update.clear()
