extends Node

signal progress_changed(progress)
signal load_done

var _load_screen_path: String = "res://scenes/loading_screen.tscn"
var _load_screen_packed: PackedScene
var _scene_path: String
var _progress: Array = []
var _loaded_resource: PackedScene
var use_sub_threads: bool = OS.has_feature("web") == false

var current_loading_screen_instance: Node = null

func _ready() -> void:
	DebugLogger.log_manager_init("LoadManager")
	_load_screen_packed = load(_load_screen_path)
	set_process(false)

func load_scene(scene_path: String) -> void:
	DebugLogger.log_scene(scene_path)
	_scene_path = scene_path
	
	var new_loading_screen = _load_screen_packed.instantiate()
	current_loading_screen_instance = new_loading_screen
	get_tree().root.add_child(new_loading_screen)
	
	new_loading_screen.continue_pressed.connect(_on_continue_pressed)

	if new_loading_screen.has_method("update_progress"):
		self.progress_changed.connect(new_loading_screen.update_progress)
	
	self.load_done.connect(new_loading_screen._start_ready_prompt)
	
	start_load()

func start_load() -> void:
	DebugLogger.log_info("Starting threaded load, use_sub_threads: " + str(use_sub_threads))
	var state = ResourceLoader.load_threaded_request(_scene_path, "", use_sub_threads)
	if state == OK:
		set_process(true)
	else:
		DebugLogger.log_error("Failed to start resource loading: " + str(state))

func _process(_delta: float) -> void:
	var load_status = ResourceLoader.load_threaded_get_status(_scene_path, _progress)
	
	match load_status:
		ResourceLoader.THREAD_LOAD_INVALID_RESOURCE, ResourceLoader.THREAD_LOAD_FAILED:
			set_process(false)
			DebugLogger.log_error("Load Failed for: " + _scene_path)
			push_error("Load Failed")
			
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			progress_changed.emit(_progress[0])
			
		ResourceLoader.THREAD_LOAD_LOADED:
			_loaded_resource = ResourceLoader.load_threaded_get(_scene_path)
			DebugLogger.log_info("Scene loaded successfully")
			progress_changed.emit(1.0)
			load_done.emit()
			set_process(false)

func _on_continue_pressed() -> void:
	DebugLogger.log_info("Continue pressed, changing scene")
	get_tree().change_scene_to_packed(_loaded_resource)
	if current_loading_screen_instance:
		current_loading_screen_instance.queue_free()
		current_loading_screen_instance = null
