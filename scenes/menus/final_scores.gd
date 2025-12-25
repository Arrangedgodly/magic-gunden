extends HBoxContainer

@onready var final_score: Label = %FinalScore
@onready var final_killcount: Label = %FinalKillcount
@onready var best_killstreak: Label = %BestKillstreak
@onready var time_alive: Label = %"Time Alive"
@onready var gems_captured: Label = %"Gems Captured"

func set_final_score(score: int) -> void:
	final_score.text = str(score)

func set_final_killcount(score: int) -> void:
	final_killcount.text = str(score)

func set_best_killsteak(score: int) -> void:
	best_killstreak.text = str(score)

func set_gems_captured(score: int) -> void:
	gems_captured.text = str(score)

func set_time_alive(score: String) -> void:
	time_alive.text = score
