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

func attempt_capture_practice() -> void:
	reset()
	append_text("If you capture more than one gem at a time, every gem beyond the first gets a score multiplier!")
	newline()
	append_text("Try to position yourself over the glowing tiles and capture multiple gems at once.")

func explain_enemy_spawn() -> void:
	reset()
	append_text("Notice how the gems you [color=red]missed[/color] turned into enemies!")
	newline()
	newline()
	append_text("This is one of the core challenges you will face:")
	newline()
	append_text("You must carefully position yourself to capture all your gems, or face the consequences.")

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

func shot_missed() -> void:
	reset()
	append_text("You missed the target!")
	newline()
	newline()
	append_text("Don't worry, we refilled your ammo.")
	newline()
	append_text("Take your time and aim carefully.")

func trail_collision() -> void:
	reset()
	append_text("Too close!")
	newline()
	append_text("You hit your own trail.")
	newline()
	newline()
	append_text("Don't cross your own path!")

func off_map() -> void:
	reset()
	append_text("Careful!")
	newline()
	append_text("You went off the path.")
	newline()
	newline()
	append_text("Let's get you back to safety.")

func enemy_collision() -> void:
	reset()
	append_text("Ouch!")
	newline()
	append_text("You ran into a slime.")
	newline()
	newline()
	append_text("Keep your distance!")

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
