extends VBoxContainer
class_name PowerupWidget

@onready var icon_rect: TextureRect = $TextureRect
@onready var progress_bar: ProgressBar = $ProgressBar

var linked_timer: Timer
var powerup_name: String = ""

func setup(p_name: String, p_timer: Timer, p_icon: Texture2D) -> void:
	powerup_name = p_name
	linked_timer = p_timer
	
	if p_icon:
		icon_rect.texture = p_icon
	
	if linked_timer.wait_time > 0:
		progress_bar.max_value = linked_timer.wait_time
		progress_bar.value = linked_timer.time_left

func _process(_delta: float) -> void:
	if not is_instance_valid(linked_timer):
		queue_free()
		return
	
	progress_bar.max_value = linked_timer.wait_time
	progress_bar.value = linked_timer.time_left
	
	if linked_timer.is_stopped() or linked_timer.time_left <= 0:
		queue_free()
