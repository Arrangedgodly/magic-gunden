extends Node

const SEQ_DELAY: float = 0.03

var _sfx_queues: Dictionary = {}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func play_start(stream: AudioStream):
	var instance = AudioStreamPlayer.new()
	instance.stream = stream
	instance.bus = "Start"
	instance.finished.connect(remove_node.bind(instance))
	add_child(instance)
	instance.play()
	
func play_sound(stream: AudioStream):
	if stream == null:
		return
		
	var specific_id = stream.get_instance_id()

	if _sfx_queues.has(specific_id):
		_sfx_queues[specific_id] += 1
		return 

	_sfx_queues[specific_id] = 0
	
	_process_sequence(stream, specific_id, false)
	
func play_sfx_loop(stream: AudioStream, pitch: float = 1.0):
	if stream == null:
		return

	var instance = AudioStreamPlayer.new()
	instance.stream = stream
	instance.bus = "SFX"
	instance.pitch_scale = pitch
	
	instance.finished.connect(instance.play)
	
	add_child(instance)
	instance.play()

func _process_sequence(stream: AudioStream, id: int, is_queued_step: bool):
	var pitch = 1.0
	if is_queued_step:
		pitch = randf_range(0.9, 1.2)
	
	_spawn_player(stream, "SFX", pitch)

	await get_tree().create_timer(SEQ_DELAY).timeout
	
	if _sfx_queues.has(id) and _sfx_queues[id] > 0:
		_sfx_queues[id] -= 1
		_process_sequence(stream, id, true) 
	else:
		_sfx_queues.erase(id)

func _spawn_player(stream: AudioStream, bus: String, pitch: float):
	var instance = AudioStreamPlayer.new()
	instance.stream = stream
	instance.bus = bus
	instance.pitch_scale = pitch
	instance.finished.connect(remove_node.bind(instance))
	add_child(instance)
	instance.play()

func play_music(stream: AudioStream):
	var instance = AudioStreamPlayer.new()
	instance.stream = stream
	instance.bus = "Music"
	instance.finished.connect(play_music.bind(stream))
	add_child(instance)
	instance.play()
	
func remove_node(instance: AudioStreamPlayer):
	instance.queue_free()

func stop(stream: AudioStream):
	var children = get_children()
	for child in children:
		if child.stream == stream:
			child.queue_free()

func pause(stream: AudioStream):
	var children = get_children()
	for child in children:
		if child.stream == stream:
			child.stream_paused = true

func resume(stream: AudioStream):
	var children = get_children()
	for child in children:
		if child.stream == stream:
			child.stream_paused = false
