extends Node

var log_buffer: Array[String] = []
var max_buffer_size: int = 100
var is_web: bool = false
var log_label: Label = null
var log_container: PanelContainer = null

func _ready() -> void:
	is_web = OS.has_feature("web")
	process_mode = Node.PROCESS_MODE_ALWAYS

	if is_web:
		_create_log_ui()
	
	log_info("DebugLogger initialized")
	log_info("Platform: " + ("WEB" if is_web else "DESKTOP"))
	log_info("Godot version: " + Engine.get_version_info().string)

func _create_log_ui() -> void:
	var canvas = CanvasLayer.new()
	canvas.layer = 1000
	add_child(canvas)

	log_container = PanelContainer.new()
	log_container.position = Vector2(10, 10)
	log_container.custom_minimum_size = Vector2(400, 300)
	canvas.add_child(log_container)

	var scroll = ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(400, 300)
	log_container.add_child(scroll)

	log_label = Label.new()
	log_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	scroll.add_child(log_label)

	log_container.hide()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_F12:
		if log_container:
			log_container.visible = !log_container.visible

func log_info(message: String) -> void:
	_log("INFO", message)

func log_warning(message: String) -> void:
	_log("WARN", message)

func log_error(message: String) -> void:
	_log("ERROR", message)

func log_scene(scene_name: String) -> void:
	log_info("Loading scene: " + scene_name)

func log_signal(signal_name: String, from: String = "") -> void:
	var msg = "Signal: " + signal_name
	if from != "":
		msg += " from " + from
	log_info(msg)

func log_resource(resource_path: String) -> void:
	log_info("Loading resource: " + resource_path)

func log_manager_init(manager_name: String) -> void:
	log_info("Manager ready: " + manager_name)

func _log(level: String, message: String) -> void:
	var timestamp = Time.get_ticks_msec()
	var log_entry = "[%d][%s] %s" % [timestamp, level, message]

	log_buffer.append(log_entry)
	if log_buffer.size() > max_buffer_size:
		log_buffer.pop_front()

	print(log_entry)

	if log_label:
		log_label.text = "\n".join(log_buffer)

	if is_web and level == "ERROR":
		JavaScriptBridge.eval("""
			console.error('%s');
		""" % log_entry.c_escape())

func dump_logs() -> String:
	return "\n".join(log_buffer)

func save_logs_to_file() -> void:
	if is_web:
		var log_text = dump_logs()
		JavaScriptBridge.eval("""
			var blob = new Blob(['%s'], {type: 'text/plain'});
			var url = URL.createObjectURL(blob);
			var a = document.createElement('a');
			a.href = url;
			a.download = 'magic_garden_log.txt';
			a.click();
		""" % log_text.c_escape())
	else:
		var file = FileAccess.open("user://debug_log.txt", FileAccess.WRITE)
		if file:
			file.store_string(dump_logs())
			file.close()
			log_info("Logs saved to: " + OS.get_user_data_dir() + "/debug_log.txt")
