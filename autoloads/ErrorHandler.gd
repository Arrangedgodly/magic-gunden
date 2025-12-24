extends Node

var crash_detected: bool = false
var last_scene: String = ""

func _ready() -> void:
	get_tree().node_added.connect(_on_node_added)

	if OS.has_feature("web"):
		var was_crashed = JavaScriptBridge.eval("localStorage.getItem('magic_garden_crashed') === 'true'")
		if was_crashed:
			DebugLogger.log_error("!!! PREVIOUS SESSION CRASHED !!!")
			DebugLogger.log_error("Last scene: " + JavaScriptBridge.eval("localStorage.getItem('magic_garden_last_scene') || 'unknown'"))
			JavaScriptBridge.eval("localStorage.setItem('magic_garden_crashed', 'false')")

func _on_node_added(node: Node) -> void:
	if node.get_parent() == get_tree().root:
		var scene_name = node.scene_file_path if node.scene_file_path else node.name
		DebugLogger.log_info("ROOT: New scene added: " + scene_name)
		last_scene = scene_name
		
		if OS.has_feature("web"):
			JavaScriptBridge.eval("localStorage.setItem('magic_garden_last_scene', '%s')" % scene_name)

func _notification(what: int) -> void:
	if what == NOTIFICATION_CRASH:
		DebugLogger.log_error("!!! CRASH DETECTED !!!")
		DebugLogger.log_error("Last scene: " + last_scene)
		crash_detected = true
		
		if OS.has_feature("web"):
			JavaScriptBridge.eval("localStorage.setItem('magic_garden_crashed', 'true')")

			var logs = DebugLogger.dump_logs()
			JavaScriptBridge.eval("""
				console.error('=== GAME CRASHED ===');
				console.error('Last Scene: %s');
				console.error('Logs:');
				console.error('%s');
			""" % [last_scene, logs.c_escape()])

func mark_safe_point(location: String) -> void:
	DebugLogger.log_info("✓ Safe point reached: " + location)
