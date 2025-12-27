extends CanvasLayer

signal continue_pressed

@onready var continue_button: Button = $ColorRect/Button
@onready var progress_bar: ProgressBar = $ColorRect/ProgressBar
@onready var label: Label = $ColorRect/Label

func _ready() -> void:
	continue_button.disabled = true
	label.text = "Loading..."
	
	progress_bar.min_value = 0
	progress_bar.max_value = 1.0
	progress_bar.value = 0
	_set_shader_progress(0)

func update_progress(value: float) -> void:
	progress_bar.value = value
	_set_shader_progress(value)
	if value == 1.0:
		_start_ready_prompt()

func _start_ready_prompt() -> void:
	progress_bar.value = 1.0
	_set_shader_progress(1.0)
	label.text = "Complete!"
	continue_button.disabled = false

func _on_button_pressed() -> void:
	continue_pressed.emit()

func _set_shader_progress(value: float) -> void:
	if progress_bar.material:
		progress_bar.material.set_shader_parameter("progress", value)
