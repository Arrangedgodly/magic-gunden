extends RichTextLabel

const WIDTH = 128
const HEIGHT = 128

var stomp_image = preload("res://assets/items/powerups/stomp.png")

var gem_frames = [
	preload("res://assets/items/gemframe1.png"),
	preload("res://assets/items/gemframe2.png"),
	preload("res://assets/items/gemframe3.png"),
	preload("res://assets/items/gemframe4.png"),
	preload("res://assets/items/gemframe5.png"),
	preload("res://assets/items/gemframe6.png")
]

var enemy_frames = [
	preload("res://assets/enemies/Slime pack/slimeframe1.png"),
	preload("res://assets/enemies/Slime pack/slimeframe2.png"),
	preload("res://assets/enemies/Slime pack/slimeframe3.png"),
	preload("res://assets/enemies/Slime pack/slimeframe4.png")
]

var capture_frames = [
	preload("res://assets/FX/capture_frame1.png"),
	preload("res://assets/FX/capture_frame2.png"),
	preload("res://assets/FX/capture_frame3.png"),
	preload("res://assets/FX/capture_frame4.png"),
	preload("res://assets/FX/capture_frame5.png"),
	preload("res://assets/FX/capture_frame6.png"),
	preload("res://assets/FX/capture_frame7.png"),
	preload("res://assets/FX/capture_frame8.png"),
	preload("res://assets/FX/capture_frame9.png")
]

var gem_animated: AnimatedTexture = AnimatedTexture.new()
var enemy_animated: AnimatedTexture = AnimatedTexture.new()
var capture_animated: AnimatedTexture = AnimatedTexture.new()

var inputs

func _ready() -> void:
	inputs = get_input_strings()
	_create_animation(gem_frames, gem_animated)
	_create_animation(enemy_frames, enemy_animated)
	_create_animation(capture_frames, capture_animated)

func _create_animation(frames: Array, animation: AnimatedTexture) -> void:
	animation.frames = frames.size()
	animation.speed_scale = 10.0
	
	for i in range(frames.size()):
		animation.set_frame_texture(i, frames[i])
		animation.set_frame_duration(i, 1.0)

func reset() -> void:
	clear()
	push_paragraph(HORIZONTAL_ALIGNMENT_CENTER)

func welcome() -> void:
	reset()
	append_text("Let's learn how to survive.")
	pop()

func movement() -> void:
	reset()
	append_text("Use %s to move around the grid." % inputs.move)
	pop()

func gem_pickup() -> void:
	reset()
	append_text("This is a gem.")
	newline()
	add_image(gem_animated, WIDTH, HEIGHT)
	newline()
	append_text("Walk over the gem to pick it up!")
	newline()
	append_text("They will form a trail behind you.")
	pop()

func capture_zones() -> void:
	reset()
	append_text("These colored tiles are Capture Zones!")
	newline()
	add_image(capture_animated, WIDTH, HEIGHT)
	newline()
	append_text("They are essential for ammo.")

func capture_gems() -> void:
	reset()
	append_text("Move so your GEM TRAIL is on top the capture zones, then press %s. The trail turns into ammo!" % inputs.detach)

func zone_movement() -> void:
	reset()
	append_text("Zones swap positions when you capture gems, or if unused too long. Watch how they flash before timing out!")

func enemy_gem() -> void:
	reset()
	append_text("Pick up another gem. You'll use it to create an enemy.")

func leave_capture() -> void:
	reset()
	append_text("Move away from the capture zones. We aren't going to capture this gem!")

func create_enemy() -> void:
	reset()
	append_text("Press %s while NOT on capture points. Gems off tiles turn into Slimes!" % inputs.detach)

func enemy_movement() -> void:
	reset()
	append_text("Slimes turn to face their destination before they move. Watch closely!")

func aiming() -> void:
	reset()
	append_text("Use %s to aim at the slime. The crosshair shows your aim direction." % inputs.aim)

func kill_enemy() -> void:
	reset()
	append_text("Press %s to shoot at the slime! Kill it before it reaches you!" % inputs.shoot)

func stomp_powerup() -> void:
	reset()
	append_text("This is a Stomp powerup!")
	newline()
	add_image(stomp_image, WIDTH, HEIGHT)
	newline()
	append_text("Walk over it to collect it.")

func test_powerup() -> void:
	reset()
	append_text("Touch the slimes to kill them! Stomp is active for a limited time.")

func final() -> void:
	reset()
	append_text("You now know the basics. Survive as long as you can!")

func prompt_continue() -> void:
	newline()
	newline()
	append_text("[Press %s to continue]" % inputs.accept)

func enemy_convert_blocked() -> void:
	reset()
	append_text("That's okay, let's try again.")

func get_input_strings() -> Dictionary:
	var controller_type = ControllerManager.get_controller_type_name()
	if controller_type == "Xbox" or controller_type == "Steam Deck":
		return {
			"move": "Left Stick/D-Pad",
			"detach": "Left Bumper/Trigger",
			"aim": "Right Stick",
			"shoot": "Right Bumper/Trigger",
			"accept": "A"
		}
	elif controller_type == "Playstation":
		return {
			"move": "Left Stick/D-Pad",
			"detach": "Left Bumper/Trigger",
			"aim": "Right Stick",
			"shoot": "Right Bumper/Trigger",
			"accept": "X"
		}
	else:
		return {
			"move": "WASD",
			"detach": "E",
			"aim": "Arrow Keys",
			"shoot": "Space",
			"accept": "Enter"
		}
