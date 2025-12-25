extends TouchScreenButton

signal button_pressed

func _ready() -> void:
	if not (OS.has_feature("web_android") or OS.has_feature("web_ios")):
		self.visible = false
		
func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			button_pressed.emit()
