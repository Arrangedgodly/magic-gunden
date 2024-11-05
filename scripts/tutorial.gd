extends Control

var tutorial_save:TutorialSave
@onready var gem_info: VBoxContainer = $ColorRect/CenterContainer/MainVbox/GemInfo
@onready var yoyo: AnimatedSprite2D = $ColorRect/CenterContainer/MainVbox/GemInfo/HBoxContainer/Yoyo
@onready var slime_info: VBoxContainer = $ColorRect/CenterContainer/MainVbox/SlimeInfo
@onready var blue_slime: AnimatedSprite2D = $ColorRect/CenterContainer/MainVbox/SlimeInfo/HBoxContainer/BlueSlime
@onready var show_in_future: VBoxContainer = $ColorRect/CenterContainer/MainVbox/Show
@onready var close: Button = $ColorRect/CenterContainer/MainVbox/Close
@onready var gem_timer: Timer = $GemTimer
@onready var slime_timer: Timer = $SlimeTimer

var show_gems: bool = false
var show_slimes: bool = false
signal tutorial_finished

func _ready() -> void:
	get_tree().paused = true
	process_mode = Node.PROCESS_MODE_ALWAYS
	gem_info.hide()
	slime_info.hide()
	show_in_future.hide()
	close.hide()
	yoyo.play("blue")
	blue_slime.play("idle_down")
	
	tutorial_save = load("user://tutorial.tres") as TutorialSave
	if tutorial_save == null:
		tutorial_save = TutorialSave.new()
	
	if tutorial_save.show_tutorial:
		show()
		show_gems = true
	else:
		tutorial_finished.emit()
		queue_free()
		
	ResourceSaver.save(tutorial_save, "user://tutorial.tres")
	
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		if gem_timer.time_left > 0:
			gem_timer.stop()
			gem_timer.emit_signal("timeout")
		elif slime_timer.time_left > 0:
			slime_timer.stop()
			slime_timer.emit_signal("timeout")
	
	if Input.is_action_just_pressed("ui_cancel"):
		tutorial_finished.emit()
		queue_free()
		
	if show_gems:
		show_gems = false
		await _show_container_info(gem_info, gem_timer)
		show_slimes = true
	
	if show_slimes:
		show_slimes = false
		await _show_container_info(slime_info, slime_timer)
		show_in_future.show()
		close.show()
		close.grab_focus()

func _show_container_info(container, timer):
	timer.start()
	container.show()
	container.modulate.a = 0
	var start_tween = create_tween()
	start_tween.tween_property(container, "modulate:a", 1, .25)
	await timer.timeout
	var finish_tween = create_tween()
	finish_tween.tween_property(container, "modulate:a", 0, .25)
	await finish_tween.finished
	container.hide()

func _on_close_pressed() -> void:
	tutorial_finished.emit()
	get_tree().paused = false
	queue_free()

func _on_yes_pressed() -> void:
	tutorial_save.show_tutorial = true
	ResourceSaver.save(tutorial_save, "user://tutorial.tres")
	_on_close_pressed()

func _on_no_pressed() -> void:
	tutorial_save.show_tutorial = false
	ResourceSaver.save(tutorial_save, "user://tutorial.tres")
	_on_close_pressed()
