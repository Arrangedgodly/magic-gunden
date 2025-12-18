extends Control
@onready var full1: TextureProgressBar = $"Full/1"
@onready var full2: TextureProgressBar = $"Full/2"
@onready var full3: TextureProgressBar = $"Full/3"
@onready var full4: TextureProgressBar = $"Full/4"
@onready var full5: TextureProgressBar = $"Full/5"
@onready var full6: TextureProgressBar = $"Full/6"
@onready var depleted1: TextureProgressBar = $"Depleted/1"
@onready var depleted2: TextureProgressBar = $"Depleted/2"
@onready var depleted3: TextureProgressBar = $"Depleted/3"
@onready var depleted4: TextureProgressBar = $"Depleted/4"
@onready var depleted5: TextureProgressBar = $"Depleted/5"
@onready var depleted6: TextureProgressBar = $"Depleted/6"
@onready var full: HBoxContainer = $Full
@onready var depleted: HBoxContainer = $Depleted
@onready var game_manager: Node2D

var ammunition : int
var ammo = Ammo.new()
var animation_speed = 5

var full_bars: Array[TextureProgressBar]
var depleted_bars: Array[TextureProgressBar]

func _ready() -> void:
	full.position = depleted.position
	
	game_manager = get_node("/root/MagicGarden/Systems/GameManager")
	game_manager.decrease_ammo.connect(decrease_ammo)
	game_manager.increase_ammo.connect(increase_ammo)
	
	full_bars = [full1, full2, full3, full4, full5, full6]
	depleted_bars = [depleted1, depleted2, depleted3, depleted4, depleted5, depleted6]

func _process(_delta: float) -> void:
	check_ammo()
	
func increase_ammo():
	ammo.increase_ammo()
	if ammo.ammo_count % 6 == 0:
		ammunition = 6
	else:
		ammunition = ammo.ammo_count % 6
	
func decrease_ammo():
	var old_ammunition = ammunition
	
	ammo.decrease_ammo()
	
	if ammo.ammo_count == 0:
		ammunition = 0
	elif ammo.ammo_count % 6 == 0:
		ammunition = 6
	else:
		ammunition = ammo.ammo_count % 6
	
	if ammo.ammo_count < 6 and old_ammunition > ammunition:
		var depleted_index = ammunition
		if depleted_index >= 0 and depleted_index < 6:
			full_bars[depleted_index].value = 0
			deplete_ammo_container(depleted_bars[depleted_index])
	else:
		for i in range(6):
			if i < ammunition:
				full_bars[i].value = 1
			else:
				full_bars[i].value = 0
	
	check_ammo()

func deplete_ammo_container(ammo_container: TextureProgressBar):
	var i = 10
	while i >= 0:
		ammo_container.value = i
		await get_tree().create_timer(0.05).timeout
		i -= 1
	
func empty_ammo():
	ammunition = 0

func check_ammo():
	for i in range(6):
		if ammunition >= i + 1:
			full_bars[i].value = 1
		else:
			full_bars[i].value = 0
