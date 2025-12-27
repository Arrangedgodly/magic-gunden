extends Resource
class_name AchievementData

@export var id: String = ""
@export var title: String = "Achievement Title"
@export_multiline var description: String = "Description of how to unlock."
@export var icon: Texture2D
@export var hidden: bool = false

@export var goal: int = 1
@export var current_progress: int = 0
@export var is_unlocked: bool = false
@export var auto_save: bool = true

func unlock() -> void:
	if not is_unlocked:
		is_unlocked = true
		current_progress = goal

func increment(amount: int = 1) -> bool:
	if is_unlocked:
		return false
		
	current_progress += amount
	if current_progress >= goal:
		current_progress = goal
		unlock()
		return true
	return false
