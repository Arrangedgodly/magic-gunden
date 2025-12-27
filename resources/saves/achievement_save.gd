extends Resource
class_name AchievementSave

@export var progress_data: Dictionary = {}

func set_progress(id: String, unlocked: bool, current_progress: int) -> void:
	progress_data[id] = {
		"unlocked": unlocked,
		"progress": current_progress
	}

func get_progress(id: String) -> Dictionary:
	return progress_data.get(id, {})
