extends Area2D
class_name PoisonTrail

@onready var sprite: Sprite2D = $Sprite2D
@onready var lifetime_timer: Timer = $LifetimeTimer

var damage_interval: float = 0.5
var damage_timers: Dictionary = {}

func _ready() -> void:
	var collision_shape = CollisionShape2D.new()
	collision_shape.shape = CircleShape2D.new()
	collision_shape.shape.radius = 16
	add_child(collision_shape)
	
	sprite = Sprite2D.new()
	sprite.modulate = Color(0.5, 1, 0.3, 0.6)
	add_child(sprite)
	
	lifetime_timer = Timer.new()
	lifetime_timer.wait_time = 3.0
	lifetime_timer.one_shot = true
	lifetime_timer.timeout.connect(_on_lifetime_timeout)
	add_child(lifetime_timer)
	lifetime_timer.start()
	
	modulate.a = 0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.7, 0.3)
	
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

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

func stop_damaging_enemy(enemy: Node2D) -> void:
	if damage_timers.has(enemy):
		var timer = damage_timers[enemy]
		timer.queue_free()
		damage_timers.erase(enemy)

func damage_enemy(enemy: Node2D) -> void:
	if is_instance_valid(enemy) and enemy.has_method("kill"):
		enemy.kill()
		stop_damaging_enemy(enemy)

func _on_lifetime_timeout() -> void:
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0, 0.5)
	await tween.finished
	queue_free()
