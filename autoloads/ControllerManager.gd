extends Node

enum ControllerType {
	XBOX,
	PLAYSTATION,
	STEAM_DECK,
	KEYBOARD
}

var current_controller_type: ControllerType = ControllerType.KEYBOARD
var connected_controllers: Dictionary = {}

const MOTION_DEADZONE = 0.2

signal controller_connected(device_id: int, controller_type: ControllerType)
signal controller_disconnected(device_id: int)
signal controller_type_changed(new_type: ControllerType)

func _ready() -> void:
	DebugLogger.log_manager_init("ControllerManager - START")
	Input.joy_connection_changed.connect(_on_joy_connection_changed)
	
	for device_id in Input.get_connected_joypads():
		_detect_controller_type(device_id)
	
	DebugLogger.log_manager_init("ControllerManager - COMPLETE")

func _input(event: InputEvent) -> void:
	if event is InputEventKey or event is InputEventMouseButton:
		_set_active_type(ControllerType.KEYBOARD)
		
	elif event is InputEventJoypadButton:
		var device_id = event.device
		_ensure_controller_detected(device_id)
		_set_active_type(connected_controllers.get(device_id, ControllerType.XBOX))
		
	elif event is InputEventJoypadMotion:
		if abs(event.axis_value) > MOTION_DEADZONE:
			var device_id = event.device
			_ensure_controller_detected(device_id)
			_set_active_type(connected_controllers.get(device_id, ControllerType.XBOX))

func _ensure_controller_detected(device_id: int) -> void:
	if not connected_controllers.has(device_id):
		_detect_controller_type(device_id)

func _set_active_type(new_type: ControllerType) -> void:
	if current_controller_type != new_type:
		current_controller_type = new_type
		controller_type_changed.emit(current_controller_type)

func _on_joy_connection_changed(device_id: int, connected: bool) -> void:
	if connected:
		_detect_controller_type(device_id)
		controller_connected.emit(device_id, connected_controllers.get(device_id, ControllerType.XBOX))
	else:
		if connected_controllers.has(device_id):
			connected_controllers.erase(device_id)
		controller_disconnected.emit(device_id)
		
		if current_controller_type != ControllerType.KEYBOARD:
			if connected_controllers.is_empty():
				_set_active_type(ControllerType.KEYBOARD)
			else:
				_set_active_type(connected_controllers.values()[0])

func _detect_controller_type(device_id: int) -> void:
	var controller_name = Input.get_joy_name(device_id).to_lower()
	var guid = Input.get_joy_guid(device_id).to_lower()
	
	var detected_type = ControllerType.XBOX
	
	if _is_steam_deck(controller_name, guid):
		detected_type = ControllerType.STEAM_DECK
	elif _is_playstation_controller(controller_name, guid):
		detected_type = ControllerType.PLAYSTATION
	else:
		detected_type = ControllerType.XBOX
	
	connected_controllers[device_id] = detected_type

func _is_playstation_controller(controller_name: String, guid: String) -> bool:
	return (
		"playstation" in controller_name or
		"dualshock" in controller_name or
		"dualsense" in controller_name or
		"ps3" in controller_name or
		"ps4" in controller_name or
		"ps5" in controller_name or
		"sony" in controller_name or
		"054c" in guid
	)

func _is_steam_deck(controller_name: String, _guid: String) -> bool:
	return (
		"steam" in controller_name or
		"deck" in controller_name or
		"valve" in controller_name
	)

func get_controller_type() -> ControllerType:
	return current_controller_type

func get_controller_type_name() -> String:
	match current_controller_type:
		ControllerType.XBOX:
			return "Xbox"
		ControllerType.PLAYSTATION:
			return "PlayStation"
		ControllerType.STEAM_DECK:
			return "Steam Deck"
		ControllerType.KEYBOARD:
			return "Keyboard"
		_:
			return "Xbox"
