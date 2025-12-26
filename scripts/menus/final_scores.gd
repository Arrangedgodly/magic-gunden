extends Control
class_name FinalScores

@onready var final_score: VBoxContainer = %FinalScoreContainer
@onready var final_killcount: VBoxContainer = %FinalKillcountContainer
@onready var best_killstreak: VBoxContainer = %BestKillstreakContainer
@onready var gems_captured: VBoxContainer = %GemsCapturedContainer
@onready var time_alive: VBoxContainer = %TimeAliveContainer
@onready var flash_score: FlashScore = %FlashScore

const ANIMATION_DELAY = 0.25

func _ready() -> void:
	final_score.hide()
	final_killcount.hide()
	best_killstreak.hide()
	gems_captured.hide()
	time_alive.hide()
	
	flash_score.final_score_flashed.connect(_on_flash_score_final_score_flashed)
	flash_score.final_killcount_flashed.connect(_on_flash_score_final_killcount_flashed)
	flash_score.best_killstreak_flashed.connect(_on_flash_score_best_killstreak_flashed)
	flash_score.gems_captured_flashed.connect(_on_flash_score_gems_captured_flashed)
	flash_score.time_alive_flashed.connect(_on_flash_score_time_alive_flashed)

func _on_flash_score_final_score_flashed() -> void:
	await get_tree().create_timer(ANIMATION_DELAY).timeout
	final_score.show()
	_await_hide()

func _on_flash_score_final_killcount_flashed() -> void:
	show()
	await get_tree().create_timer(ANIMATION_DELAY).timeout
	final_killcount.show()
	_await_hide()

func _on_flash_score_best_killstreak_flashed() -> void:
	show()
	await get_tree().create_timer(ANIMATION_DELAY).timeout
	best_killstreak.show()
	_await_hide()

func _on_flash_score_gems_captured_flashed() -> void:
	show()
	await get_tree().create_timer(ANIMATION_DELAY).timeout
	gems_captured.show()
	_await_hide()

func _on_flash_score_time_alive_flashed() -> void:
	show()
	await get_tree().create_timer(ANIMATION_DELAY).timeout
	time_alive.show()

func _await_hide() -> void:
	await get_tree().create_timer(ANIMATION_DELAY).timeout
	hide()
