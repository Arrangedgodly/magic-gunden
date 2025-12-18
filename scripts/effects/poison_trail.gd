extends Area2D
class_name PoisonTrail

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var lifetime_timer: Timer = $LifetimeTimer

var damage_interval: float = 0.5
var damage_timers: Dictionary = {}

var poison_sound: AudioStream = preload("res://assets/sounds/sfx/potion_bubbles_brewing_loop_01.wav")

func _ready() -> void:
	add_to_group("laser_exception")
	
	lifetime_timer.timeout.connect(_on_lifetime_timeout)
	lifetime_timer.start()
	
	modulate.a = 0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.7, 0.3)
	
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	AudioManager.play_sfx_loop(poison_sound)

func _on_body_entered(body: Node2D) -> void:
	if body is Slime:
		start_damaging_enemy(body)

func _on_body_exited(body: Node2D) -> void:
	if body is Slime:
		stop_damaging_enemy(body)

func start_damaging_enemy(enemy: Node2D) -> void:
	if damage_timers.has(enemy):
		return
	
	var timer = Timer.new()
	timer.wait_time = damage_interval
	timer.timeout.connect(func(): damage_enemy(enemy))
	add_child(timer)
	timer.start()
	damage_timers[enemy] = timer
	enemy.show_poison()

func stop_damaging_enemy(enemy: Node2D) -> void:
	if damage_timers.has(enemy):
		var timer = damage_timers[enemy]
		timer.queue_free()
		damage_timers.erase(enemy)
		enemy.hide_poison()

func damage_enemy(enemy: Node2D) -> void:
	if is_instance_valid(enemy) and enemy.has_method("kill"):
		enemy.kill()
		stop_damaging_enemy(enemy)

func _on_lifetime_timeout() -> void:
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0, 0.5)
	await tween.finished
	AudioManager.stop(poison_sound)
	queue_free()
