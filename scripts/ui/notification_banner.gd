extends PanelContainer

@onready var icon_rect: TextureRect = %Icon
@onready var name_label: Label = %NameLabel

func setup(achievement: AchievementData) -> void:
	name_label.text = achievement.title
	if achievement.icon:
		icon_rect.texture = achievement.icon
	
	position.y = 950
	modulate.a = 0.0
	
	_animate_in()

func _animate_in() -> void:
	var tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	tween.tween_property(self, "position:y", 700.0, 0.5)
	tween.parallel().tween_property(self, "modulate:a", 1.0, 0.3)
	
	tween.tween_interval(3.0)
	tween.tween_callback(_animate_out)

func _animate_out() -> void:
	var tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	
	tween.tween_property(self, "position:y", 950, 0.5)
	tween.parallel().tween_property(self, "modulate:a", 0.0, 0.3)
	
	tween.tween_callback(queue_free)
