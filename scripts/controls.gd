extends Control
@onready var keyboard: Node2D = $Keyboard
@onready var controller: Node2D = $Controller

func handle_input_event(event: InputEvent) -> void:
	if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		keyboard.hide()
		controller.show()
	if event is InputEventKey or event is InputEventMouseMotion:
		keyboard.show()
		controller.hide()
