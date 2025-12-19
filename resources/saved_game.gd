class_name SavedGame
extends Resource

@export var score:int
@export var slimes_killed:int
@export var gems_captured:int
@export var time_alive:int
@export var killstreak:int

func increase_score(score_to_add: int) -> int:
	score += score_to_add
	
	return score

func set_score(new_score: int) -> void:
	score = new_score

func increase_slimes_killed(kills_to_add: int) -> void:
	slimes_killed += kills_to_add

func set_slimes_killed(new_killcount: int) -> void:
	slimes_killed = new_killcount

func increase_gems_captured(gems_to_add: int) -> void:
	gems_captured += gems_to_add

func set_gems_captured(new_gem_count: int) -> void:
	gems_captured = new_gem_count

func increase_time_alive(time_to_add: int) -> void:
	time_alive += time_to_add

func set_time_alive(new_time_alive: int) -> void:
	time_alive = new_time_alive

func get_time_alive_in_minutes() -> String:
	@warning_ignore("integer_division")
	var minutes = time_alive / 60
	var leftover_seconds = time_alive % 60
	var seconds_string
	if leftover_seconds < 10:
		seconds_string = "0" + str(leftover_seconds)
	else:
		seconds_string = str(leftover_seconds)
	var time_string = str(minutes) + ":" + seconds_string
	return time_string

func increase_killstreak(killstreak_to_add: int) -> void:
	killstreak += killstreak_to_add

func set_killstreak(new_killstreak: int) -> void:
	killstreak = new_killstreak
