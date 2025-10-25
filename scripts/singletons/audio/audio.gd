extends Node

enum AUDIO_BUS {MASTER = 0, MIX, BGM, SFX, UI}

const MAX_HZ := 20500.0
const MIN_HZ := 750.0
const MIN_AMP := 0.0
const MAX_AMP := 5.0

var low_pass: AudioEffectLowPassFilter:
	get: return AudioServer.get_bus_effect(AUDIO_BUS.MIX, 0)
var amp: AudioEffectAmplify:
	get: return AudioServer.get_bus_effect(AUDIO_BUS.MASTER, 1)
	
func get_cutoff() -> float:
	return low_pass.cutoff_hz
func get_amp_db() -> float:
	return amp.volume_db
func get_bus_str(bus: AUDIO_BUS) -> StringName:
	return AudioServer.get_bus_name(bus)

func set_low_pass(val: float) -> void:
	low_pass.cutoff_hz = clamp(val, MIN_HZ, MAX_HZ)
	
func reset_low_pass() -> void:
	low_pass.cutoff_hz = MAX_HZ
	
func set_sfx_vol(val: float) -> void:
	AudioServer.set_bus_volume_db(AUDIO_BUS.SFX, _percent_to_db(val))
func set_bgm_vol(val: float) -> void:
	AudioServer.set_bus_volume_db(AUDIO_BUS.BGM, _percent_to_db(val))
func set_ui_vol(val: float) -> void:
	AudioServer.set_bus_volume_db(AUDIO_BUS.UI, _percent_to_db(val))
func set_master_vol(val: float) -> void:
	AudioServer.set_bus_volume_db(AUDIO_BUS.MASTER, _percent_to_db(val))
func set_reverb(b: bool) -> void:
	AudioServer.set_bus_effect_enabled(AUDIO_BUS.SFX, 0, b)

func _percent_to_db(val: float) -> float:
	var val_n: float = clampf(val, 0.0, 100.0) / 100.0
	return linear_to_db(val_n)

func _ready() -> void:
	get_tree().scene_changed.connect(reset_low_pass)
