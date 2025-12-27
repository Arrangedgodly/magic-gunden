extends Node

signal achievement_unlocked(achievement: AchievementData)
signal achievement_progress(achievement: AchievementData)

var achievements: Dictionary = {}

const ACHIEVEMENT_PATH = "res://resources/achievements/"
const SAVE_PATH = "user://achievements.tres"

func _ready() -> void:
	DebugLogger.log_manager_init("AchievementManager - START")
	_load_all_achievements()
	_load_save_data()
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
					var runtime_data = resource.duplicate()
					achievements[runtime_data.id] = runtime_data
			file_name = dir.get_next()
	else:
		DebugLogger.log_error("Could not open achievement directory!")

func _load_save_data() -> void:
	var save_file = SaveHelper.load_achievement_save()
	
	if not save_file:
		return

	for id in save_file.progress_data:
		if achievements.has(id):
			var saved_entry = save_file.progress_data[id]
			var runtime_achiev = achievements[id]
			
			runtime_achiev.is_unlocked = saved_entry.get("unlocked", false)
			runtime_achiev.current_progress = saved_entry.get("progress", 0)
			
			if runtime_achiev.is_unlocked:
				runtime_achiev.current_progress = runtime_achiev.goal

func _save_to_disk() -> void:
	var new_save = AchievementSave.new()
	
	for id in achievements:
		var data = achievements[id]
		new_save.set_progress(id, data.is_unlocked, data.current_progress)
	
	SaveHelper.save_achievement_save(new_save)

func unlock_achievement(id: String) -> void:
	if not achievements.has(id):
		DebugLogger.log_error("Achievement ID not found: " + id)
		return
		
	var achiev = achievements[id]
	if not achiev.is_unlocked:
		achiev.unlock()
		achievement_unlocked.emit(achiev)
		DebugLogger.log_info("Achievement Unlocked: " + achiev.title)
		_save_to_disk()

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
	
	_save_to_disk()

func reset_all_achievements() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
	
	for id in achievements:
		achievements[id].is_unlocked = false
		achievements[id].current_progress = 0
		
	DebugLogger.log_info("Achievements reset.")
