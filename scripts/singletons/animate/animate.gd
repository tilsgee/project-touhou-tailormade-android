extends Node

const OFFSET_Y := 25.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func fade_in(obj: Object, dur: float = 0.4, create_sfx := false) -> AutoTween:
	if create_sfx:
		_create_sfx()
	AutoTween.kill_all(obj)
	AutoTween.new(obj, &"position", Vector2.ZERO, dur/1.1).from(Vector2(0.0, OFFSET_Y)).ignore_engine_time().ignore_pause()
	return AutoTween.new(obj, &"modulate:a", 1.0, dur).from(0.0).ignore_engine_time().ignore_pause()
	
func fade_out(obj: Object, dur: float = 0.3, create_sfx := false) -> AutoTween:
	if create_sfx:
		_create_sfx(false)
	AutoTween.kill_all(obj)
	AutoTween.new(obj, &"position", Vector2(0.0, OFFSET_Y), dur/1.1).from(Vector2.ZERO).ignore_engine_time().ignore_pause()
	return AutoTween.new(obj, &"modulate:a", 0.0, dur).ignore_engine_time().ignore_pause()

func _create_sfx(is_accept := true) -> void:
	var sfx := AudioStreamPlayer.new()
	sfx.bus = Audio.get_bus_str(Audio.AUDIO_BUS.UI)
	sfx.finished.connect(func(): if sfx != null and sfx.get_tree() != null: sfx.queue_free())
	if is_accept:
		sfx.stream = load(&"res://external_assets/fantasy-ui-sfx/Fantasy_UI (19).wav")
	else:
		sfx.stream = load(&"res://external_assets/fantasy-ui-sfx/Fantasy_UI (60).wav")
	add_child(sfx)
	sfx.play()
