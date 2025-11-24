extends Node

signal progress_changed(progress)
signal load_done

var _load_screen_path: String = "res://scenes/loading_screen.tscn"
var _load_screen_packed: PackedScene
var _scene_path: String
var _progress: Array = []
var _loaded_resource: PackedScene

# Toggle this depending on platform (Web often needs this false unless headers are set)
var use_sub_threads: bool = true 

var current_loading_screen_instance: Node = null

func _ready() -> void:
	_load_screen_packed = load(_load_screen_path)
	set_process(false)

func load_scene(scene_path: String) -> void:
	_scene_path = scene_path
	
	var new_loading_screen = _load_screen_packed.instantiate()
	current_loading_screen_instance = new_loading_screen
	get_tree().root.add_child(new_loading_screen)
	
	new_loading_screen.continue_pressed.connect(_on_continue_pressed)
	
	# Connect the progress signal
	if new_loading_screen.has_method("update_progress"):
		self.progress_changed.connect(new_loading_screen.update_progress)
	
	self.load_done.connect(new_loading_screen._start_ready_prompt)
	
	start_load()

func start_load() -> void:
	var state = ResourceLoader.load_threaded_request(_scene_path, "", use_sub_threads)
	if state == OK:
		set_process(true)

func _process(_delta: float) -> void:
	var load_status = ResourceLoader.load_threaded_get_status(_scene_path, _progress)
	
	match load_status:
		ResourceLoader.THREAD_LOAD_INVALID_RESOURCE, ResourceLoader.THREAD_LOAD_FAILED:
			set_process(false)
			push_error("Load Failed")
			
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			progress_changed.emit(_progress[0])
			
		ResourceLoader.THREAD_LOAD_LOADED:
			_loaded_resource = ResourceLoader.load_threaded_get(_scene_path)
			
			progress_changed.emit(1.0)
			load_done.emit()
			set_process(false)

func _on_continue_pressed() -> void:
	get_tree().change_scene_to_packed(_loaded_resource)
	if current_loading_screen_instance:
		current_loading_screen_instance.queue_free()
		current_loading_screen_instance = null
