extends VBoxContainer
class_name FlashScore

@onready var scores_node: FinalScores = %Scores
@onready var score_name: Label = %Scorename
@onready var score_amount: Label = %Scoreamount

var score_sfx: AudioStream = preload("res://assets/sounds/sfx/Retro Impact LoFi 09.wav")

var scores: Array
var score_text: Array[String]
var score_values: Array[String]
var score_signals: Array[Signal]
var target_transforms: Array[Dictionary] = []
var final_score: int
var final_killcount: int
var best_killsteak: int
var gems_captured: int
var time_alive: String
var start_position: Vector2
var score_manager: ScoreManager

const READ_TIME = 0.75
const ANIMATION_DELAY = 0.25

signal final_score_flashed
signal final_killcount_flashed
signal best_killstreak_flashed
signal gems_captured_flashed
signal time_alive_flashed
signal animation_finished

func _ready() -> void:
	hide()
	
	score_manager = get_node_or_null("/root/MagicGarden/Systems/ScoreManager")
	
	scores = scores_node.get_children()
	
	start_position = global_position
	
	score_text = [
		"FINAL\nSCORE",
		"FINAL\nKILL COUNT",
		"BEST\nKILLSTREAK",
		"TOTAL\nGEMS CAPTURED",
		"TOTAL\nTIME ALIVE"
	]
	
	score_signals = [
		final_score_flashed,
		final_killcount_flashed,
		best_killstreak_flashed,
		gems_captured_flashed,
		time_alive_flashed
	]
	
	score_manager.game_ended.connect(_on_score_manager_game_ended)

func _on_score_manager_game_ended(saved_game: SavedGame) -> void:
	final_score = saved_game.score
	final_killcount = saved_game.slimes_killed
	best_killsteak = saved_game.killstreak
	gems_captured = saved_game.gems_captured
	time_alive = saved_game.get_time_alive_in_minutes()
	
	score_values = [
		str(final_score),
		str(final_killcount),
		str(best_killsteak),
		str(gems_captured),
		time_alive
	]
	
	for node in scores:
		node.show()
	
	await get_tree().process_frame
	
	target_transforms.clear()
	for node in scores:
		target_transforms.append({
			"pos": node.global_position,
			"size": node.size
		})
		node.hide()
	
	handle_animation()
	
func handle_animation() -> void:
	set_anchors_preset(Control.PRESET_TOP_LEFT)
	
	for i in range(scores.size()):
		AudioManager.play_sound(score_sfx)
		
		var target_data = target_transforms[i]
		
		global_position = Vector2.ZERO
		size = Vector2(1280, 800)
		
		score_name.add_theme_constant_override("outline_size", 30)
		score_amount.add_theme_constant_override("outline_size", 60)
		score_name.add_theme_font_size_override("font_size", 128)
		score_amount.add_theme_font_size_override("font_size", 256)
		score_name.text = score_text[i]
		score_amount.text = score_values[i]
		
		show()
		await get_tree().create_timer(READ_TIME).timeout
		
		score_signals[i].emit()
		
		var tween = create_tween().set_parallel(true)
		tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(self, "global_position", target_data["pos"], ANIMATION_DELAY)
		tween.tween_property(self, "size", target_data["size"], ANIMATION_DELAY)
		tween.tween_property(score_name, "theme_override_constants/outline_size", 10, ANIMATION_DELAY)
		tween.tween_property(score_amount, "theme_override_constants/outline_size", 20, ANIMATION_DELAY)
		tween.tween_property(score_name, "theme_override_font_sizes/font_size", 32, ANIMATION_DELAY)
		tween.tween_property(score_amount, "theme_override_font_sizes/font_size", 64, ANIMATION_DELAY)
		await tween.finished
		
		hide()
		
		await get_tree().create_timer(ANIMATION_DELAY).timeout
	
	animation_finished.emit()
