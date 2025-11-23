extends CanvasLayer

signal continue_pressed

@onready var continue_button: Button = $ColorRect/Button
@onready var progress_bar: ProgressBar = $ColorRect/ProgressBar

var tween: Tween

func _ready() -> void:
	continue_button.disabled = true
	continue_button.visible = false
	layer = 100 

func update_progress(value: float) -> void:
	if progress_bar:
		if tween: tween.kill()
		tween = create_tween()
		tween.tween_property(progress_bar, "value", value * 100, 0.2)

func _start_ready_prompt() -> void:
	if tween: tween.kill()
	if progress_bar: progress_bar.value = 100
	
	continue_button.disabled = false
	continue_button.visible = true
	continue_button.grab_focus()
	
	continue_button.modulate.a = 0
	var t = create_tween()
	t.tween_property(continue_button, "modulate:a", 1.0, 0.5)

func _on_button_pressed() -> void:
	continue_pressed.emit()
