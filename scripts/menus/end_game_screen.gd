extends Control
@onready var yes: Button = %Yes
@onready var no: Button = %No
@onready var ui: Control = %UI
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

var score_manager: ScoreManager

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
		
	hide()
	
func _on_score_manager_game_ended(final_saved_game) -> void:
	final_score.text = str(final_saved_game.score)
	final_killcount.text = str(final_saved_game.slimes_killed)
	best_killstreak.text = str(final_saved_game.killstreak)
	time_alive.text = final_saved_game.get_time_alive_in_minutes()
	gems_captured.text = str(final_saved_game.gems_captured)
	show()
	yes.grab_focus()
	ui.hide()

func _on_no_pressed() -> void:
	hide()
	get_tree().change_scene_to_file("res://scenes/menus/main_menu.tscn")

func _on_yes_pressed() -> void:
	hide()
	get_tree().change_scene_to_file("res://scenes/magic_garden.tscn")

func _on_score_manager_new_highscore(new_score: int) -> void:
	final_score_label.text = "NEW BEST HIGH SCORE"
	final_score.text = str(new_score)

func _on_score_manager_new_high_killcount(new_killcount: int) -> void:
	final_killcount_label.text = "NEW TOP KILL COUNT"
	final_killcount.text = str(new_killcount)

func _on_score_manager_new_high_killstreak(new_killstreak: int) -> void:
	best_killstreak_label.text = "NEW BEST KILLSTREAK"
	best_killstreak.text = str(new_killstreak)

func _on_score_manager_new_high_time_alive(new_time_alive: int) -> void:
	time_alive_label.text = "NEW LONGEST TIME ALIVE"
	time_alive.text = str(new_time_alive)

func _on_score_manager_new_high_gems_captured(new_gems_captured: int) -> void:
	gems_captured_label.text = "NEW TOP GEMS CAPTURED"
	gems_captured.text = str(new_gems_captured)

func _on_yes_focus_entered() -> void:
	yes.get_material().set_shader_parameter("speed", 2)

func _on_yes_focus_exited() -> void:
	yes.get_material().set_shader_parameter("speed", 0)

func _on_no_focus_entered() -> void:
	no.get_material().set_shader_parameter("speed", 2)

func _on_no_focus_exited() -> void:
	no.get_material().set_shader_parameter("speed", 0)
