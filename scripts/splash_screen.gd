extends Control
@onready var godot_splash: Sprite2D = $"CenterContainer/Godot Splash"
@onready var gurpy_games: VBoxContainer = $CenterContainer/VBoxContainer
@onready var black_background: ColorRect = $BlackBackground
@onready var rainbow_background: ColorRect = $RainbowBackground

@export var godot_sound: AudioStream
@export var gurpy_games_sound: AudioStream

var splash_finished : bool = false

func _ready() -> void:
	godot_splash.modulate = Color(1, 1, 1, 0)
	var screen_height = get_viewport().get_visible_rect().size.y
	godot_splash.position.y -= screen_height
	gurpy_games.modulate = Color(1, 1, 1, 0)
	await trigger_godot_splash()
	await trigger_gurpy_games()
	await get_tree().create_timer(1).timeout
	splash_finished = true

func _process(_delta: float) -> void:
	if splash_finished or Input.is_action_just_pressed("ui_cancel") or Input.is_action_just_pressed("menu") or Input.is_action_just_pressed("ui_accept"):
		AudioManager.stop(godot_sound)
		AudioManager.stop(gurpy_games_sound)
		get_tree().change_scene_to_file("res://scenes/menus/main_menu.tscn")
	
func trigger_godot_splash() -> void:
	var tween = create_tween()
	tween.tween_property(godot_splash, "modulate", Color(1, 1, 1, 1), 4).set_trans(Tween.TRANS_SINE)
	tween.parallel().tween_property(godot_splash, "position", Vector2(-140, -32), 2).set_trans(Tween.TRANS_SINE)
	AudioManager.play_start(godot_sound)
	tween.tween_callback(trigger_godot_melting_out)
	tween.tween_property(godot_splash, "modulate", Color(1, 1, 1, 0), 2).set_trans(Tween.TRANS_SINE)
	tween.parallel().tween_property(godot_splash, "position", Vector2(-140, 250), 2).set_trans(Tween.TRANS_SINE)
	await tween.finished

func trigger_gurpy_games() -> void:
	var tween = create_tween()
	tween.tween_property(gurpy_games, "modulate", Color(1, 1, 1, 1), 2).set_trans(Tween.TRANS_SINE)
	tween.parallel().tween_property(black_background, "modulate", Color(1, 1, 1, 0), 2).set_trans(Tween.TRANS_SINE)
	AudioManager.play_start(gurpy_games_sound)
	flash_gg_box()
	tween.tween_property(gurpy_games, "modulate", Color(1, 1, 1, 0), 2).set_trans(Tween.TRANS_SINE)
	tween.parallel().tween_property(black_background, "modulate", Color(1, 1, 1, 1), 2).set_trans(Tween.TRANS_SINE)
	await tween.finished

func flash_gg_box():
	var children = gurpy_games.get_children()
	for child in children:
		var tween = create_tween()
		tween.set_parallel(false)
		tween.tween_property(child, "theme_override_colors/font_color", Color(255, 0, 0, 1), .25).set_trans(Tween.TRANS_SINE)
		tween.tween_property(child, "theme_override_colors/font_color", Color(0, 255, 0, 1), .25).set_trans(Tween.TRANS_SINE)
		tween.tween_property(child, "theme_override_colors/font_color", Color(0, 0, 255, 1), .25).set_trans(Tween.TRANS_SINE)
		tween.tween_property(child, "theme_override_colors/font_color", Color(255, 0, 0, 1), .25).set_trans(Tween.TRANS_SINE)
		tween.tween_property(child, "theme_override_colors/font_color", Color(0, 255, 0, 1), .25).set_trans(Tween.TRANS_SINE)
		tween.tween_property(child, "theme_override_colors/font_color", Color(0, 0, 255, 1), .25).set_trans(Tween.TRANS_SINE)
		tween.tween_property(child, "theme_override_colors/font_color", Color(255, 0, 0, 1), .25).set_trans(Tween.TRANS_SINE)
		tween.tween_property(child, "theme_override_colors/font_color", Color(0, 255, 0, 1), .25).set_trans(Tween.TRANS_SINE)
		tween.tween_property(child, "theme_override_colors/font_color", Color(0, 0, 255, .75), .25).set_trans(Tween.TRANS_SINE)
		tween.tween_property(child, "theme_override_colors/font_color", Color(255, 0, 0, .75), .25).set_trans(Tween.TRANS_SINE)
		tween.tween_property(child, "theme_override_colors/font_color", Color(0, 255, 0, .75), .25).set_trans(Tween.TRANS_SINE)
		tween.tween_property(child, "theme_override_colors/font_color", Color(0, 0, 255, .75), .25).set_trans(Tween.TRANS_SINE)
		tween.tween_property(child, "theme_override_colors/font_color", Color(255, 0, 0, .25), .25).set_trans(Tween.TRANS_SINE)
		tween.tween_property(child, "theme_override_colors/font_color", Color(0, 255, 0, .25), .25).set_trans(Tween.TRANS_SINE)
		tween.tween_property(child, "theme_override_colors/font_color", Color(0, 0, 255, .25), .25).set_trans(Tween.TRANS_SINE)
		tween.tween_property(child, "theme_override_colors/font_color", Color(255, 0, 0, .25), .25).set_trans(Tween.TRANS_SINE)
		
func trigger_godot_melting_out():
	var godot_splash_material = godot_splash.get_material()
	var i = 0
	while i < 1:
		godot_splash_material.set_shader_parameter("progress", i)
		await get_tree().create_timer(.05).timeout
		i += 0.025
