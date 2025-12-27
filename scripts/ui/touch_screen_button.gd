extends TouchScreenButton

signal button_pressed

func _ready() -> void:
	var controller_type = ControllerManager.get_controller_type_name()
	
	if controller_type != "Touch":
		hide()
		return
	
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	button_pressed.emit()
