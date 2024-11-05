extends AnimatedSprite2D

const animations = [
	'bars', 'dots', 'fold', 'hole', 'kaleidescope', 'lines', 'sea', 'squares', 'wavy'
]

func handle_animation_swap():
	randomize()
	var random_number = randi_range(0, len(animations) - 1)
	self.play(animations[random_number])

func _on_background_swap_timeout() -> void:
	handle_animation_swap()
	
func _ready() -> void:
	handle_animation_swap()
