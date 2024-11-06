extends CanvasLayer

signal ls_ready
signal continue_pressed

@onready var texture_progress_bar: TextureProgressBar = $ColorRect/TextureProgressBar
@onready var continue_button: Button = $ColorRect/Button
@onready var label: Label = $ColorRect/HBoxContainer/Label
@onready var ellipsis_container: HBoxContainer = $"ColorRect/HBoxContainer/Ellipsis Container"
@onready var dot1: Label = $"ColorRect/HBoxContainer/Ellipsis Container/Dot1"
@onready var dot2: Label = $"ColorRect/HBoxContainer/Ellipsis Container/Dot2"
@onready var dot3: Label = $"ColorRect/HBoxContainer/Ellipsis Container/Dot3"
@onready var sprites: Node = $Sprites

var is_loading: bool = true
var tween: Tween

func _ready() -> void:
	continue_button.disabled = true
	label.text = "Loading"
	start_dot_animation()
	var sprite_nodes = sprites.get_children()
	var random_sprite = randi_range(0, 3)
	for sprite in sprites.get_children():
		sprite.hide()
	sprite_nodes[random_sprite].show()
	await get_tree().create_timer(.1).timeout
	ls_ready.emit()

func _update_progress_bar(new_value: float) -> void:
	texture_progress_bar.set_value_no_signal(new_value * 100)
	texture_progress_bar.tint_progress.a = new_value
	
func _start_ready_prompt() -> void:
	is_loading = false
	if tween:
		tween.kill()
	
	# Animate the transition to "Ready!"
	var ready_tween = create_tween()
	ready_tween.tween_callback(func(): ellipsis_container.hide())
	ready_tween.tween_property(label, "modulate:a", 0.0, 0.2)
	ready_tween.tween_callback(func(): label.text = "Ready!")
	ready_tween.tween_property(label, "modulate:a", 1.0, 0.2)
	
	continue_button.disabled = false
	continue_button.grab_focus()
	
func start_dot_animation() -> void:
	if tween:
		tween.kill()
	
	tween = create_tween().set_loops()
	
	# Dot 1 animation
	tween.parallel().tween_property(dot1, "position:y", -10.0, 0.3).set_trans(Tween.TRANS_SINE)
	tween.parallel().tween_property(dot1, "position:y", 0.0, 0.3).set_trans(Tween.TRANS_SINE).set_delay(0.3)
	
	# Dot 2 animation (delayed start)
	tween.parallel().tween_property(dot2, "position:y", -10.0, 0.3).set_trans(Tween.TRANS_SINE).set_delay(0.1)
	tween.parallel().tween_property(dot2, "position:y", 0.0, 0.3).set_trans(Tween.TRANS_SINE).set_delay(0.4)
	
	# Dot 3 animation (delayed start)
	tween.parallel().tween_property(dot3, "position:y", -10.0, 0.3).set_trans(Tween.TRANS_SINE).set_delay(0.2)
	tween.parallel().tween_property(dot3, "position:y", 0.0, 0.3).set_trans(Tween.TRANS_SINE).set_delay(0.5)

func _start_outro_animation() -> void:
	queue_free()

func _on_button_pressed() -> void:
	continue_pressed.emit()
