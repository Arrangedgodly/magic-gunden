extends Powerup
class_name TimePausePowerup

@onready var grayscale_shader: Shader = preload("res://shaders/black_and_white.gdshader")

var frozen_enemy_list: Array = []
var enemy_manager: EnemyManager
var frozen_capture_list: Array = []
var capture_point_manager: CapturePointManager
var warning_tween: Tween = null
var grids: Node2D

const WARNING_TIME: float = 2.0

func _ready() -> void:
	super._ready()
	type = PowerupType.TimePause

func activate(manager: PowerupManager) -> void:
	super.activate(manager)
	manager.register_time_pause_powerup(self)
	manager.powerup_activated.emit("TimePause")
	
	enemy_manager = manager.enemy_manager
	freeze_all_enemies()
	
	capture_point_manager = get_node("/root/MagicGarden/Systems/CapturePointManager")
	freeze_all_capture_points()
	
	grids = get_node("/root/MagicGarden/World/Grids")
	freeze_grids()
	
	await get_tree().create_timer(duration - WARNING_TIME).timeout
	if is_active:
		start_warning_flash()

func get_powerup_name() -> String:
	return "TimePause"

func freeze_all_enemies() -> void:
	frozen_enemy_list.clear()
	
	enemy_manager.stop_enemy_systems()
	
	var enemies = get_tree().get_nodes_in_group("mobs")
	for enemy_instance in enemies:
		if is_instance_valid(enemy_instance):
			frozen_enemy_list.append(enemy_instance)
			
			var enemy_sprite = enemy_instance.sprite
			enemy_sprite.pause()
			var new_material = ShaderMaterial.new()
			new_material.shader = grayscale_shader
			enemy_sprite.material = new_material
			enemy_sprite.get_material().set_shader_parameter("mix_amount", 1.0)
			
			enemy_instance.set_meta("is_time_frozen", true)

func start_warning_flash() -> void:
	for enemy_instance in frozen_enemy_list:
		if is_instance_valid(enemy_instance):
			var enemy_sprite = enemy_instance.sprite
			
			var flash_tween = create_tween()
			flash_tween.set_loops(0)
			
			flash_tween.tween_property(enemy_sprite.material, "shader_parameter/mix_amount", 0.2, 0.3)
			flash_tween.tween_property(enemy_sprite.material, "shader_parameter/mix_amount", 1.0, 0.3)
			
			enemy_instance.set_meta("time_freeze_flash_tween", flash_tween)
	
	for capture_point in frozen_capture_list:
		if is_instance_valid(capture_point):
			var flash_tween = create_tween()
			flash_tween.set_loops(0)
			
			flash_tween.tween_property(capture_point.material, "shader_parameter/mix_amount", 0.2, 0.3)
			flash_tween.tween_property(capture_point.material, "shader_parameter/mix_amount", 1.0, 0.3)
	
	if is_instance_valid(grids):
		var flash_tween = create_tween()
		flash_tween.set_loops(0)
			
		flash_tween.tween_property(grids.material, "shader_parameter/mix_amount", 0.2, 0.3)
		flash_tween.tween_property(grids.material, "shader_parameter/mix_amount", 1.0, 0.3)

func unfreeze_all_enemies() -> void:
	enemy_manager.start_enemy_systems()
	
	for enemy_instance in frozen_enemy_list:
		if is_instance_valid(enemy_instance):
			if enemy_instance.has_meta("time_freeze_flash_tween"):
				var flash_tween = enemy_instance.get_meta("time_freeze_flash_tween")
				if flash_tween and flash_tween.is_valid():
					flash_tween.kill()
				enemy_instance.remove_meta("time_freeze_flash_tween")
			
			var enemy_sprite = enemy_instance.sprite
			enemy_sprite.material = null
			enemy_sprite.play()
			
			if enemy_instance.has_meta("is_time_frozen"):
				enemy_instance.remove_meta("is_time_frozen")
	
	frozen_enemy_list.clear()

func freeze_all_capture_points() -> void:
	frozen_capture_list.clear()
	
	capture_point_manager.stop_capture_systems()
	
	var capture_points = get_tree().get_nodes_in_group("capture")
	for point in capture_points:
		if is_instance_valid(point):
			frozen_capture_list.append(point)
			var new_material = ShaderMaterial.new()
			new_material.shader = grayscale_shader
			point.material = new_material
			point.get_material().set_shader_parameter("mix_amount", 1.0)
			point.stop()

func unfreeze_all_capture_points() -> void:
	capture_point_manager.start_capture_systems()
	
	for capture_point in frozen_capture_list:
		if is_instance_valid(capture_point):
			capture_point.material = null
			capture_point.play()
	
	frozen_capture_list.clear()

func freeze_grids() -> void:
	var new_material = ShaderMaterial.new()
	new_material.shader = grayscale_shader
	grids.material = new_material
	grids.get_material().set_shader_parameter("mix_amount", 1.0)

func unfreeze_grids() -> void:
	grids.material = null

func _on_timeout() -> void:
	unfreeze_all_enemies()
	unfreeze_all_capture_points()
	unfreeze_grids()
	super._on_timeout()
