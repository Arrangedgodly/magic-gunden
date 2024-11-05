extends Control
@onready var warning_text: Label = %WarningText
signal confirmation(confirmation_bool: bool)
@onready var yes: Button = $CenterContainer/VBoxContainer/HBoxContainer/YES
@onready var no: Button = $CenterContainer/VBoxContainer/HBoxContainer/NO

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

func set_warning_text(new_text: String):
	warning_text.text = new_text

func _on_yes_pressed() -> void:
	confirmation.emit(true)

func _on_no_pressed() -> void:
	confirmation.emit(false)

func enable_focus():
	yes.grab_focus()

func _on_yes_focus_entered() -> void:
	yes.get_material().set_shader_parameter("speed", 2)

func _on_yes_focus_exited() -> void:
	yes.get_material().set_shader_parameter("speed", 0)

func _on_no_focus_entered() -> void:
	no.get_material().set_shader_parameter("speed", 2)

func _on_no_focus_exited() -> void:
	no.get_material().set_shader_parameter("speed", 0)
