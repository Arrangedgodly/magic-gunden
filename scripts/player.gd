extends CharacterBody2D
class_name Player

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var move_timer: Timer = $"../MoveTimer"
@onready var game_manager: Node2D = $"../GameManager"
@onready var crosshair: Sprite2D = $Crosshair
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var yoyo_scene = preload("res://scenes/yoyo.tscn")
var score_popup_scene = preload("res://scenes/score_popup.tscn")
var projectile_scene = preload("res://scenes/projectile.tscn")

var last_direction = null
var aim_direction = down
var is_ricochet_active: bool = false
var animation_speed = 5

const tile_size = 32
const up = Vector2(0, -1)
const down = Vector2(0, 1)
const left = Vector2(-1, 0)
const right = Vector2(1, 0)


func _ready():
	position = position.snapped(Vector2.ONE * tile_size)
	position += Vector2.ONE * 8
	powerup_active()

func _process(_delta: float) -> void:
	var input_vector = Vector2(
		Input.get_action_strength("move-right") - Input.get_action_strength("move-left"),
		Input.get_action_strength("move-down") - Input.get_action_strength("move-up")
	)
	
	if Input.is_action_just_pressed("move-left") and last_direction != right:
		last_direction = left
		animation_tree.set("parameters/Run/BlendSpace2D/blend_position", input_vector)
		animation_tree["parameters/playback"].travel("Run")
	if Input.is_action_just_pressed("move-right") and last_direction != left:
		last_direction = right
		animation_tree.set("parameters/Run/BlendSpace2D/blend_position", input_vector)
		animation_tree["parameters/playback"].travel("Run")
	if Input.is_action_just_pressed("move-up") and last_direction != down:
		last_direction = up
		animation_tree.set("parameters/Run/BlendSpace2D/blend_position", input_vector)
		animation_tree["parameters/playback"].travel("Run")
	if Input.is_action_just_pressed("move-down") and last_direction != up:
		last_direction = down
		animation_tree.set("parameters/Run/BlendSpace2D/blend_position", input_vector)
		animation_tree["parameters/playback"].travel("Run")
		
	if Input.is_action_just_pressed("aim-down"):
		aim_direction = down
	if Input.is_action_just_pressed("aim-up"):
		aim_direction = up
	if Input.is_action_just_pressed("aim-left"):
		aim_direction = left
	if Input.is_action_just_pressed("aim-right"):
		aim_direction = right
		
func die():
	game_manager.end_game()
	animation_tree.set("parameters/Death/BlendSpace2D/blend_position", last_direction)
	animation_tree.get("parameters/playback").travel("Death")
	set_process(false)
	move_timer.stop()

func create_score_popup(value):
	var score_popup = score_popup_scene.instantiate()
	score_popup.position += Vector2(-6, -25)
	add_child(score_popup)
	score_popup.handle_popup(value)

func attack():
	var projectile = projectile_scene.instantiate()
	projectile.set_direction(aim_direction)
	
	if game_manager.piercing_active:
		projectile.is_piercing = true
	
	if is_ricochet_active:
		projectile.can_ricochet = true
		projectile.max_bounces = 3
		
	add_child(projectile)

func activate_ricochet() -> void:
	is_ricochet_active = true

func ricochet_timeout() -> void:
	is_ricochet_active = false

func powerup_active():
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", Color(1, 0, 0), .5).set_trans(Tween.TRANS_SINE)
	tween.tween_property(sprite, "modulate", Color(1, 1, 1), .5).set_trans(Tween.TRANS_SINE)
	tween.tween_property(sprite, "modulate", Color(1, 0, 0), .5).set_trans(Tween.TRANS_SINE)
	tween.tween_property(sprite, "modulate", Color(1, 1, 1), .5).set_trans(Tween.TRANS_SINE)
	tween.tween_property(sprite, "modulate", Color(1, 0, 0), .5).set_trans(Tween.TRANS_SINE)
	tween.tween_property(sprite, "modulate", Color(1, 1, 1), .5).set_trans(Tween.TRANS_SINE)
	tween.tween_property(sprite, "modulate", Color(1, 0, 0), .5).set_trans(Tween.TRANS_SINE)
	tween.tween_property(sprite, "modulate", Color(1, 1, 1), .5).set_trans(Tween.TRANS_SINE)
	tween.tween_property(sprite, "modulate", Color(1, 0, 0), .5).set_trans(Tween.TRANS_SINE)
	tween.tween_property(sprite, "modulate", Color(1, 1, 1), .5).set_trans(Tween.TRANS_SINE)
