class_name CameraShaker extends RefCounted

const SHAKE_PERIOD := 0.05

signal shake_finished

static var _instances: Array[CameraShaker]

var _dur_timer: SceneTreeTimer
var _phy_timer: SceneTreeTimer
var _strength: float
var _duration: float
var _direction: Vector2
var _continuous: bool
var _dir := 1

func stop() -> void:
	_dur_timeout()
	
func _init(strength := 12.0, duration := 0.5, direction := Vector2.ONE, continuous := false) -> void:
	for i in _instances:
		if i._strength > strength:
			return
	_strength = strength
	_duration = duration
	_direction = direction.normalized()
	_continuous = continuous
	if !continuous:
		_dur_timer = Camera.instance.get_tree().create_timer(_duration)
		_dur_timer.timeout.connect(_dur_timeout)
	_create_phy_timer()
	_instances.append(self)

func _create_phy_timer() -> void:
	if !is_instance_valid(Camera.instance):
		return
	_phy_timer = Camera.instance.get_tree().create_timer(SHAKE_PERIOD)
	_phy_timer.timeout.connect(func():
		if (_dur_timer == null and !_continuous) or _phy_timer == null:
			return
		_create_phy_timer()
		_shake()
	, CONNECT_ONE_SHOT)
	
func _shake() -> void:
	var dur_normalized := (_dur_timer.time_left / _duration) if !_continuous else 1.0
	var rng = Vector2(
		randf_range(-_strength * _direction.x, _strength * _direction.x),
		randf_range(-_strength * _direction.y, _strength * _direction.y)
	).abs()
	_dir *= -1
	rng *= dur_normalized * _dir
	if Camera.instance != null:
		AutoTween.new(Camera.instance, &"shake_offset", rng, SHAKE_PERIOD, Tween.TRANS_LINEAR)
	
func _dur_timeout() -> void:
	_dur_timer = null
	_phy_timer = null
	Camera.shake_offset = Vector2.ZERO 
	shake_finished.emit()
	_instances.erase(self)
