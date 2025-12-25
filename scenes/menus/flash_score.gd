extends VBoxContainer

@onready var scores_node: Control = %Scores
@onready var score_name: Label = %Scorename
@onready var score_amount: Label = %Scoreamount

var scores: Array
var timer: Timer

const ANIMATION_DELAY = 0.75

func _ready() -> void:
	scores = scores_node.get_children()
	
	timer = Timer.new()
	timer.wait_time = ANIMATION_DELAY
	timer.start()

func handle_animation() -> void:
	for i in range(scores.size()):
		pass
