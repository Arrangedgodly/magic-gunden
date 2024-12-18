extends Node

signal progress_changed(progress)
signal load_done
signal scene_ready_to_change

var _load_screen_path: String = "res://scenes/loading_screen.tscn"
var _load_screen = load(_load_screen_path)
var _loaded_resource: PackedScene
var _scene_path: String
var _progress: Array = []
var use_sub_threads: bool = true

func _ready() -> void:
	set_process(false)

func load_scene(scene_path: String) -> void:
	_scene_path = scene_path
	
	var new_loading_screen = _load_screen.instantiate()
	get_tree().get_root().add_child(new_loading_screen)
	self.progress_changed.connect(new_loading_screen._update_progress_bar)
	self.load_done.connect(new_loading_screen._start_ready_prompt)
	self.scene_ready_to_change.connect(new_loading_screen._start_outro_animation)
	
	new_loading_screen.ls_ready.connect(start_load)
	new_loading_screen.continue_pressed.connect(_change_scene)
	
func start_load() -> void:
	var state = ResourceLoader.load_threaded_request(_scene_path, "", use_sub_threads)
	if state == OK:
		set_process(true)

func _process(_delta: float) -> void:
	var load_status = ResourceLoader.load_threaded_get_status(_scene_path, _progress)
	match load_status:
		0, 2: #? THREAD_LOAD_INVALID_RESOURCE, THREAD_LOAD_FAILED
			set_process(false)
			return
		1: #? THREAD_LOAD_IN_PROGRESS
			progress_changed.emit(_progress[0])
		3: #? THREAD_LOAD_LOADED
			_loaded_resource = ResourceLoader.load_threaded_get(_scene_path)
			progress_changed.emit(1.0)
			load_done.emit()
			set_process(false)

func _change_scene() -> void:
	scene_ready_to_change.emit()
	get_tree().change_scene_to_packed(_loaded_resource)
