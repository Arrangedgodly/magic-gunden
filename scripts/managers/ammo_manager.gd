extends Node2D
class_name AmmoManager

@onready var ammo_error_sfx: AudioStream = preload("res://assets/sounds/sfx/error_style_3_001.wav")
@onready var score_manager: ScoreManager = %ScoreManager
@onready var player: CharacterBody2D = %Player

var ammo = Ammo.new()

signal current_ammo(ammo_count: int)
signal decrease_ammo
signal increase_ammo

func handle_attack():
	if ammo.ammo_count == 0:
		AudioManager.play_sound(ammo_error_sfx)
		score_manager.reset_current_killstreak()
		
	if ammo.ammo_count >= 1:
		decrease_ammo.emit()
		ammo.decrease_ammo()
		await player.attack()
		
	current_ammo.emit(ammo.ammo_count)

func increase_ammo_count() -> void:
	increase_ammo.emit()
	ammo.increase_ammo()
	current_ammo.emit(ammo.clip_count)
