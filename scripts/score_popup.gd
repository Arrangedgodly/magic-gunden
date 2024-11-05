extends Node2D
@onready var label: Label = $Label
@export var stream: AudioStream

var can_flash : bool

func _ready() -> void:
	self.visible = false

func handle_popup(value: int) -> void:
	self.visible = true
	AudioManager.play_sound(stream)
	label.text = str(value)
	var tween = create_tween().set_parallel(true)
	tween.tween_property(label, "scale", Vector2(1.25, 1.25), 1)
	var target_pos = label.position + (Vector2.UP * 25)
	tween.tween_property(label, "position", target_pos, 1)
	tween.tween_property(self, "visible", false, 1)
	await tween.finished

func _process(_delta: float) -> void:
	if can_flash:
		self.modulate = Color(20, 20, 20, 1)
		can_flash = false
	else:
		self.modulate = Color(1, 1, 1, 1)
		can_flash = true
