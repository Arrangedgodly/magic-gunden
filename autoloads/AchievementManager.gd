extends Node

signal achievement_unlocked(achievement: AchievementData)
signal achievement_progress(achievement: AchievementData)

var achievements: Dictionary = {}

const ACHIEVEMENT_PATH = "res://resources/achievements/"

func _ready() -> void:
	DebugLogger.log_manager_init("AchievementManager - START")
	_load_all_achievements()
	DebugLogger.log_manager_init("AchievementManager - COMPLETE")

func _load_all_achievements() -> void:
	var dir = DirAccess.open(ACHIEVEMENT_PATH)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tres") or file_name.ends_with(".remap"):
				file_name = file_name.replace(".remap", "")
				
				var resource = load(ACHIEVEMENT_PATH + file_name) as AchievementData
				if resource:
					resource.current_progress = 0
					resource.is_unlocked = false
					achievements[resource.id] = resource
			file_name = dir.get_next()
	else:
		DebugLogger.log_error("Could not open achievement directory!")

func unlock_achievement(id: String) -> void:
	if not achievements.has(id):
		DebugLogger.log_error("Achievement ID not found: " + id)
		return
		
	var achiev = achievements[id]
	if not achiev.is_unlocked:
		achiev.unlock()
		achievement_unlocked.emit(achiev)
		DebugLogger.log_info("Achievement Unlocked: " + achiev.title)
		# TODO: Save game here

func progress_achievement(id: String, amount: int = 1) -> void:
	if not achievements.has(id):
		return
		
	var achiev = achievements[id]
	var just_unlocked = achiev.increment(amount)
	
	if just_unlocked:
		achievement_unlocked.emit(achiev)
		DebugLogger.log_info("Achievement Unlocked via Progress: " + achiev.title)
	else:
		achievement_progress.emit(achiev)
