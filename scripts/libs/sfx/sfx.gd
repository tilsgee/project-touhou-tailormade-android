class_name SFX extends RefCounted

signal finished

static var audio_streams: Array

const META := &"audio_stream"
const RANDOM_PITCH := 1.1
const MAX_POLYPHONY := 5
const PANNING_STRENGTH := 2.0

const playlist := {
	&"player": {
		&"hit": [preload("uid://0one3yj6ydby")],
		&"shoot": {
			&"bullet_small": [preload("uid://b0t276j08dod8")]
		},
		&"dead": [preload("uid://kywepy3cov6q")],
		&"bomb": [preload("uid://dooknh61q6cv")]
	},
	&"enemy": {
		&"hit": [preload("uid://d28sods76t6gh")],
		&"dead": [preload("uid://b0kgjv3ex87nh")],
		&"ghost_haunt": [preload("uid://xl1q50e1xttp")],
		&"shoot": [preload("uid://bmpg6ehqsso00")]
	},
	&"objects": {
		&"explode": [preload("uid://d28sods76t6gh")],
		&"item_picked": [preload("uid://bun7blg3wydfv")],
		&"money_cash": [preload("uid://cban4l5ojy35a")],
		&"customer_leave": [preload("uid://d3r5gxdjitn5q")], # “buwok” sfx
		&"cloth": [preload("uid://c8p1y3cgo3xe0")]
	},
	&"dialogue": {
		
	},
	&"ui": {
		&"spellcard": [preload("uid://cnftrt0c3errp")],
		
		&"ui_select": [preload("uid://pqa1aimdmi71")],
		&"ui_accept": [preload("uid://dusm1p26bntke")],
		&"ui_cancel": [preload("uid://wtjh1jd1nwmd")],
	},
}

var stream_player: AudioStreamPlayer2D

func set_pitch_change(val: float) -> SFX:
	if stream_player != null:
		(stream_player.stream as AudioStreamRandomizer).random_pitch = val
	return self

func no_pitch_change() -> SFX:
	return set_pitch_change(1.0)

func is_ui() -> SFX:
	if stream_player != null:
		stream_player.bus = Audio.get_bus_str(Audio.AUDIO_BUS.UI)
	return process_always()

func process_always() -> SFX:
	if stream_player != null:
		stream_player.process_mode = Node.PROCESS_MODE_ALWAYS
	return self

## FIXME: Memory leak
func _init(node: Node, streams: Array, options := {&"volume_db": 0.0}) -> void:
	stream_player = _get_stream_from_node(node, streams)
	if stream_player == null:
		stream_player = _create_stream(node, streams)
		stream_player.bus = Audio.get_bus_str(Audio.AUDIO_BUS.SFX)
		# Doing some random JS bullsh*t to see if it works
		stream_player.stream = (func() -> AudioStreamRandomizer:
			var stream = AudioStreamRandomizer.new()
			for i in range(streams.size()):
				stream.add_stream(i, streams[i])
			stream.random_pitch = RANDOM_PITCH
			return stream
		).call()
		
		# Reparent to 'other_nodes' if the parent is destroyed
		# FIXME: Putting callable here does not work somehow, it has to be lambda
		node.tree_exited.connect(func(): _reparent_stream())
		
		stream_player.finished.connect(finished.emit)
	
	for o in options.keys():
		stream_player.set(o, options[o])
	
	stream_player.play.call_deferred()

func _create_stream(node: Node, stream: Array) -> AudioStreamPlayer2D:
	var instance := AudioStreamPlayer2D.new()
	instance.max_polyphony = MAX_POLYPHONY
	instance.panning_strength = PANNING_STRENGTH
	audio_streams.append(instance)
	node.set_meta(_get_hash(stream), instance)
	node.add_child(instance)
	return instance

func _delete_stream() -> void:
	audio_streams.erase(stream_player)
	if is_instance_valid(stream_player):
		stream_player.queue_free()

func _reparent_stream():
	if !is_instance_valid(stream_player):
		return
	if !stream_player.playing:
		_delete_stream()
		return
	stream_player.reparent(Arena.other_nodes)
	# FIXME: This too, has to be lambda
	finished.connect(func(): _delete_stream())

func _get_stream_from_node(node: Node, stream: Array) -> AudioStreamPlayer2D:
	var meta = _get_hash(stream)
	if is_instance_valid(node) and node.has_meta(meta):
		return node.get_meta(meta) if node.get_meta(meta) != null else null
	return null

func _get_hash(stream) -> String:
	return META + str(stream.hash())
