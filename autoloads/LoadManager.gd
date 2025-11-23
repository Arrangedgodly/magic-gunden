extends Node

signal progress_changed(progress)
signal load_done

var _load_screen_path: String = "res://scenes/loading_screen.tscn"
var _load_screen_packed: PackedScene
var _scene_path: String
var _progress: Array = []
var _loaded_resource: PackedScene

# SETTINGS
var use_sub_threads: bool = true
var min_load_time: float = 3.0 # Force load screen to stay for at least 3 seconds

# STATE
var current_loading_screen_instance: Node = null
var time_elapsed: float = 0.0

func _ready() -> void:
	_load_screen_packed = load(_load_screen_path)
	set_process(false)

func load_scene(scene_path: String) -> void:
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
	var state = ResourceLoader.load_threaded_request(_scene_path, "", use_sub_threads)
	if state == OK:
		time_elapsed = 0.0 # Reset timer
		set_process(true)

func _process(delta: float) -> void:
	# 1. Update Timer
	time_elapsed += delta
	
	# 2. Get Real Load Status
	var load_status = ResourceLoader.load_threaded_get_status(_scene_path, _progress)
	
	# Safe retrieval of real percentage (0.0 to 1.0)
	var real_progress = _progress[0] if _progress.size() > 0 else 0.0
	
	# 3. Calculate "Fake" Time Percentage (0.0 to 1.0)
	var time_progress = time_elapsed / min_load_time
	
	# 4. The "Smart" Progress Bar Logic
	# We show whichever is LOWER. 
	# - If PC is fast (Real=1.0) but Timer is slow (Time=0.2), show 0.2.
	# - If PC is slow (Real=0.1) but Timer is done (Time=1.0), show 0.1.
	var display_progress = min(real_progress, time_progress)
	
	progress_changed.emit(display_progress)
	
	match load_status:
		ResourceLoader.THREAD_LOAD_INVALID_RESOURCE, ResourceLoader.THREAD_LOAD_FAILED:
			set_process(false)
			push_error("Load Failed")
			
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			# Continue processing...
			pass
			
		ResourceLoader.THREAD_LOAD_LOADED:
			# 5. Completion Condition
			# Only finish if REAL load is done AND Timer is done
			if time_elapsed >= min_load_time:
				_loaded_resource = ResourceLoader.load_threaded_get(_scene_path)
				progress_changed.emit(1.0)
				load_done.emit()
				set_process(false)

func _on_continue_pressed() -> void:
	get_tree().change_scene_to_packed(_loaded_resource)
	if current_loading_screen_instance:
		current_loading_screen_instance.queue_free()
		current_loading_screen_instance = null
