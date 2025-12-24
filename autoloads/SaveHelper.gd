extends Node

func load_resource(path: String, expected_type = null) -> Resource:
	"""
	Safely load a resource from user:// directory
	Returns null if file doesn't exist or fails to load
	"""
	DebugLogger.log_info("Attempting to load: " + path)
	
	if not ResourceLoader.exists(path):
		DebugLogger.log_info("Resource doesn't exist: " + path)
		return null

	var resource = ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE)
	
	if resource == null:
		DebugLogger.log_warning("Resource exists but failed to load: " + path)
		return null

	if expected_type != null and not is_instance_of(resource, expected_type):
		DebugLogger.log_error("Resource loaded but wrong type. Expected: " + str(expected_type))
		return null
	
	DebugLogger.log_info("Successfully loaded: " + path)
	return resource

func save_resource(resource: Resource, path: String) -> bool:
	"""
	Safely save a resource to user:// directory
	Returns true if successful, false otherwise
	"""
	DebugLogger.log_info("Attempting to save: " + path)
	
	if resource == null:
		DebugLogger.log_error("Cannot save null resource")
		return false
	
	var result = ResourceSaver.save(resource, path)
	
	if result == OK:
		DebugLogger.log_info("Successfully saved: " + path)
		return true
	else:
		DebugLogger.log_error("Failed to save: " + path + " (Error: " + str(result) + ")")
		return false

func delete_save(path: String) -> bool:
	"""
	Delete a saved resource
	Returns true if successful or file didn't exist
	"""
	DebugLogger.log_info("Attempting to delete: " + path)
	
	if not ResourceLoader.exists(path):
		DebugLogger.log_info("File doesn't exist, nothing to delete: " + path)
		return true

	if OS.has_feature("web"):
		DebugLogger.log_info("Web platform - overwriting with empty resource instead of deleting")
		return true
	else:
		var result = DirAccess.remove_absolute(path)
		if result == OK:
			DebugLogger.log_info("Successfully deleted: " + path)
			return true
		else:
			DebugLogger.log_error("Failed to delete: " + path + " (Error: " + str(result) + ")")
			return false

func save_exists(path: String) -> bool:
	"""
	Check if a save file exists
	"""
	return ResourceLoader.exists(path)

func load_settings() -> SettingsSave:
	var settings = load_resource("user://settings.tres", SettingsSave)
		
	if settings == null:
		DebugLogger.log_info("Creating new settings")
		settings = SettingsSave.new()
		settings.set_default_controls()
		
	return settings

func save_settings(settings: SettingsSave) -> bool:
	return save_resource(settings, "user://settings.tres")

func load_tutorial_save() -> TutorialSave:
	var tutorial = load_resource("user://tutorial.tres", TutorialSave) as TutorialSave
	if tutorial == null:
		DebugLogger.log_info("Creating default tutorial save")
		tutorial = TutorialSave.new()
	return tutorial

func save_tutorial_save(tutorial: TutorialSave) -> bool:
	return save_resource(tutorial, "user://tutorial.tres")

func load_high_scores() -> SavedGame:
	var scores = load_resource("user://save.tres", SavedGame) as SavedGame
	if scores == null:
		DebugLogger.log_info("No high scores found")
		scores = SavedGame.new()
	return scores

func save_high_scores(scores: SavedGame) -> bool:
	return save_resource(scores, "user://save.tres")

func reset_all_saves() -> void:
	DebugLogger.log_info("Resetting all saves...")
	delete_save("user://settings.tres")
	delete_save("user://tutorial.tres")
	delete_save("user://save.tres")
	DebugLogger.log_info("All saves reset")
