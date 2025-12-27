extends Node

signal progress_changed(progress)
signal load_done

var _load_screen_path: String = "res://scenes/loading_screen.tscn"
var _load_screen_packed: PackedScene
var _scene_path: String
var _progress: Array = []
var _loaded_resource: PackedScene
var use_sub_threads: bool = not (OS.has_feature("web") or OS.has_feature("mobile"))
var current_loading_screen_instance: Node = null
var is_web_loading: bool = false

func _ready() -> void:
	DebugLogger.log_manager_init("LoadManager - START")
	DebugLogger.log_info("Threading enabled: " + str(use_sub_threads))
	_load_screen_packed = load(_load_screen_path)
	set_process(false)
	DebugLogger.log_manager_init("LoadManager - COMPLETE")

func load_scene(scene_path: String) -> void:
	DebugLogger.log_info("LoadManager.load_scene: " + scene_path)
	_scene_path = scene_path
	
	var new_loading_screen = _load_screen_packed.instantiate()
	current_loading_screen_instance = new_loading_screen
	get_tree().root.add_child(new_loading_screen)

	if new_loading_screen.has_method("update_progress"):
		self.progress_changed.connect(new_loading_screen.update_progress)
	
	if OS.has_feature("web") or OS.has_feature("mobile"):
		DebugLogger.log_info("Using web-safe loading...")
		_start_web_load()
	else:
		DebugLogger.log_info("Using threaded loading...")
		start_load()

func start_load() -> void:
	"""Desktop/native threaded loading"""
	var state = ResourceLoader.load_threaded_request(_scene_path, "", use_sub_threads)
	if state == OK:
		DebugLogger.log_info("Threaded load started successfully")
		set_process(true)
	else:
		DebugLogger.log_error("Failed to start threaded load: " + str(state))

func _start_web_load() -> void:
	"""Web-safe non-threaded loading with fake progress"""
	is_web_loading = true
	_simulate_loading_progress()

func _simulate_loading_progress() -> void:
	progress_changed.emit(0)
	
	await get_tree().process_frame

	DebugLogger.log_info("Loading scene resource...")
	_loaded_resource = ResourceLoader.load(_scene_path, "", ResourceLoader.CACHE_MODE_REUSE) as PackedScene
	
	if _loaded_resource == null:
		DebugLogger.log_error("Failed to load scene: " + _scene_path)
		return
	
	DebugLogger.log_info("Scene resource loaded successfully")
	
	progress_changed.emit(1.0)
	load_done.emit()
	is_web_loading = false

	await get_tree().create_timer(0.3).timeout
	_change_to_loaded_scene()

func _process(_delta: float) -> void:
	"""Desktop/native threaded loading process"""
	if is_web_loading:
		return
	
	var load_status = ResourceLoader.load_threaded_get_status(_scene_path, _progress)
	
	match load_status:
		ResourceLoader.THREAD_LOAD_INVALID_RESOURCE, ResourceLoader.THREAD_LOAD_FAILED:
			set_process(false)
			DebugLogger.log_error("Threaded load failed for: " + _scene_path)
			push_error("Load Failed")
			
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			progress_changed.emit(_progress[0])
			
		ResourceLoader.THREAD_LOAD_LOADED:
			_loaded_resource = ResourceLoader.load_threaded_get(_scene_path)
			DebugLogger.log_info("Threaded load complete")
			progress_changed.emit(1.0)
			load_done.emit()
			set_process(false)

			get_tree().create_timer(0.3).timeout.connect(_change_to_loaded_scene)

func _change_to_loaded_scene() -> void:
	"""Change to the loaded scene and cleanup"""
	DebugLogger.log_info("Transitioning to loaded scene...")
	
	if _loaded_resource == null:
		DebugLogger.log_error("Cannot change scene: loaded resource is null!")
		_cleanup_loading_screen()
		return

	if is_instance_valid(current_loading_screen_instance):
		if current_loading_screen_instance.get_child_count() > 0:
			var visual_root = current_loading_screen_instance.get_child(0)
			if visual_root and "modulate" in visual_root:
				var tween = create_tween()
				tween.tween_property(visual_root, "modulate:a", 0.0, 0.3)
				await tween.finished

	var old_scene = get_tree().current_scene
	if old_scene:
		DebugLogger.log_info("Freeing old scene: " + old_scene.name)
		old_scene.queue_free()

		await get_tree().process_frame
		await get_tree().process_frame

	DebugLogger.log_info("Instantiating new scene...")
	var new_scene_instance = _loaded_resource.instantiate()

	_loaded_resource = null 
	
	get_tree().root.add_child(new_scene_instance)
	get_tree().current_scene = new_scene_instance
	
	DebugLogger.log_info("Scene swap complete")
	
	await get_tree().create_timer(0.25).timeout
	_cleanup_loading_screen()

func _cleanup_loading_screen() -> void:
	if is_instance_valid(current_loading_screen_instance):
		current_loading_screen_instance.queue_free()
		current_loading_screen_instance = null

func quick_load(scene_path: String) -> void:
	var scene = ResourceLoader.load(scene_path)
	if scene:
		DebugLogger.log_info("Successfully loaded %s" % scene_path)
		get_tree().call_deferred("change_scene_to_packed", scene)
	else:
		DebugLogger.log_error("Failed to load %s scene" % scene_path)
