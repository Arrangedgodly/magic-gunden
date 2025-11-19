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
@onready var game_manager: Node2D = $"../../../GameManager"

var ammunition : int
var ammo = Ammo.new()
var animation_speed = 5

func _ready() -> void:
	full.position = depleted.position
	game_manager.decrease_ammo.connect(decrease_ammo)
	game_manager.increase_ammo.connect(increase_ammo)

func _process(_delta: float) -> void:
	check_ammo()
	
func increase_ammo():
	ammo.increase_ammo()
	if ammo.ammo_count % 6 == 0:
		ammunition = 6
	else:
		ammunition = ammo.ammo_count % 6
	
func decrease_ammo():
	ammo.decrease_ammo()
	if ammo.ammo_count == 0:
		ammunition = 0
	elif ammo.ammo_count % 6 == 0:
		ammunition = 6
	else:
		ammunition = ammo.ammo_count % 6
	if ammunition == 5:
		full6.value = 0
		deplete_ammo_container(depleted6)
	if ammunition == 4:
		full5.value = 0
		deplete_ammo_container(depleted5)
	if ammunition == 3:
		full4.value = 0
		deplete_ammo_container(depleted4)
	if ammunition == 2:
		full3.value = 0
		deplete_ammo_container(depleted3)
	if ammunition == 1:
		full2.value = 0
		deplete_ammo_container(depleted2)
	if ammunition == 0:
		full1.value = 0
		deplete_ammo_container(depleted1)
	
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
	if ammunition >= 1:
		full1.value = 1
	if ammunition >= 2:
		full2.value = 1
	if ammunition >= 3:
		full3.value = 1
	if ammunition >= 4:
		full4.value = 1
	if ammunition >= 5:
		full5.value = 1
	if ammunition >= 6:
		full6.value = 1	
