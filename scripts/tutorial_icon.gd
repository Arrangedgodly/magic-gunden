extends AnimatedSprite2D

func show_gem() -> void:
	self.play("gem")
	self.scale = Vector2(10, 10)

func show_capture() -> void:
	self.play("capture")
	self.scale = Vector2(3.5, 3.5)

func show_enemy() -> void:
	self.play("enemy")
	self.scale = Vector2(5, 5)
