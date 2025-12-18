extends Control
@onready var yes: Button = $CenterContainer/VBoxContainer/HBoxContainer/Yes
@onready var no: Button = $CenterContainer/VBoxContainer/HBoxContainer/No
@onready var ui: Control = %UI
@onready var final_score: Label = $CenterContainer/VBoxContainer/HBoxContainer3/VBoxContainer/FinalScore
@onready var final_score_label: Label = $"CenterContainer/VBoxContainer/HBoxContainer3/VBoxContainer/Final Score Label"
@onready var final_killcount_label: Label = $"CenterContainer/VBoxContainer/HBoxContainer3/VBoxContainer2/Final Killcount Label"
@onready var final_killcount: Label = $CenterContainer/VBoxContainer/HBoxContainer3/VBoxContainer2/FinalKillcount
@onready var time_alive_label: Label = $"CenterContainer/VBoxContainer/HBoxContainer3/VBoxContainer4/Time Alive Label"
@onready var time_alive: Label = $"CenterContainer/VBoxContainer/HBoxContainer3/VBoxContainer4/Time Alive"
@onready var gems_captured_label: Label = $"CenterContainer/VBoxContainer/HBoxContainer3/VBoxContainer3/Gems Captured Label"
@onready var gems_captured: Label = $"CenterContainer/VBoxContainer/HBoxContainer3/VBoxContainer3/Gems Captured"

func _ready() -> void:
	hide()
	
func _on_game_manager_game_ended(new_score: int, new_killcount: int, new_time_alive: int, new_gems_captured: int) -> void:
	final_score.text = str(new_score)
	final_killcount.text = str(new_killcount)
	time_alive.text = convert_time_to_minutes(new_time_alive)
	gems_captured.text = str(new_gems_captured)
	show()
	yes.grab_focus()
	ui.hide()

func _on_no_pressed() -> void:
	hide()
	get_tree().change_scene_to_file("res://scenes/menus/main_menu.tscn")

func _on_yes_pressed() -> void:
	hide()
	get_tree().change_scene_to_file("res://scenes/magic_garden.tscn")

func _on_game_manager_new_highscore(new_score: int) -> void:
	final_score_label.text = "NEW BEST HIGH SCORE"
	final_score.text = str(new_score)

func _on_game_manager_new_high_killcount(new_killcount: int) -> void:
	final_killcount_label.text = "NEW TOP KILL COUNT"
	final_killcount.text = str(new_killcount)

func _on_game_manager_new_high_time_alive(new_time_alive: int) -> void:
	time_alive_label.text = "NEW LONGEST TIME ALIVE"
	time_alive.text = str(new_time_alive)

func _on_game_manager_new_high_gems_captured(new_gems_captured: int) -> void:
	gems_captured_label.text = "NEW TOP GEMS CAPTURED"
	gems_captured.text = str(new_gems_captured)
	
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

func _on_yes_focus_entered() -> void:
	yes.get_material().set_shader_parameter("speed", 2)

func _on_yes_focus_exited() -> void:
	yes.get_material().set_shader_parameter("speed", 0)

func _on_no_focus_entered() -> void:
	no.get_material().set_shader_parameter("speed", 2)

func _on_no_focus_exited() -> void:
	no.get_material().set_shader_parameter("speed", 0)
