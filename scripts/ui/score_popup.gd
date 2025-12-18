extends Node2D

@onready var label: Label = $Label
@export var stream: AudioStream

var can_flash : bool

var velocity: Vector2 = Vector2.ZERO
var gravity: float = 600.0
var friction: float = 300.0

func _ready() -> void:
	self.visible = false

func handle_popup(value: int) -> void:
	self.visible = true
	AudioManager.play_sound(stream)
	label.text = str(value)
	
	var x_jitter = randf_range(-10, 10)
	position = Vector2(x_jitter, -50)
	velocity = Vector2(randf_range(-120, 120), randf_range(-250, -320))

	var tween = create_tween().set_parallel(true)

	label.scale = Vector2.ZERO
	tween.tween_property(label, "scale", Vector2(1.25, 1.25), 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

	tween.tween_property(self, "modulate:a", 0.0, 0.3).set_delay(0.6)

	tween.chain().tween_callback(queue_free)

func _process(delta: float) -> void:
	velocity.y += gravity * delta
	velocity.x = move_toward(velocity.x, 0, friction * delta)
	position += velocity * delta
	
	if can_flash:
		self.modulate = Color(20, 20, 20, self.modulate.a)
		can_flash = false
	else:
		self.modulate = Color(1, 1, 1, self.modulate.a)
		can_flash = true
