class_name NodeShaker extends RefCounted

const SHAKE_PERIOD := 0.05

signal shake_finished

var _node: Node
var _dur_timer: SceneTreeTimer
var _phy_timer: SceneTreeTimer
var _strength: float
var _duration: float
var _direction: Vector2
var _continuous: bool
var _prev_node_pos: Vector2
var _trans: Tween.TransitionType
var _dir := 1

func stop() -> void:
	_dur_timeout()
	
func _init(node: Node, strength: float, direction: Vector2, duration: float, continuous: bool, transition_type: Tween.TransitionType) -> void:
	_node = node
	_strength = strength
	_duration = duration
	_direction = direction.normalized()
	_continuous = continuous
	_prev_node_pos = _node.position
	_trans = transition_type
	if !continuous:
		_dur_timer = node.get_tree().create_timer(_duration)
		_dur_timer.timeout.connect(_dur_timeout)
	_create_phy_timer()

func _create_phy_timer() -> void:
	if _node == null: return
	if !_node.is_inside_tree(): return
	_phy_timer = _node.get_tree().create_timer(SHAKE_PERIOD)
	_phy_timer.timeout.connect(func():
		if (_dur_timer == null and !_continuous) or _phy_timer == null:
			return
		_create_phy_timer()
		_shake()
	, CONNECT_ONE_SHOT) # Putting the callable directly doesn't work (???)
	
func _shake():
	var dur_normalized := (_dur_timer.time_left / _duration) if !_continuous else 1.0
	var rng = Vector2(
		randf_range(-_strength * _direction.x, _strength * _direction.x),
		randf_range(-_strength * _direction.y, _strength * _direction.y)
	).abs()
	_dir *= -1
	rng *= dur_normalized * _dir
	AutoTween.Method.new(SceneManager, func(val):
		if _node == null:
			stop()
			return
		_node.position = val,
	_prev_node_pos,
	_prev_node_pos + rng,
	SHAKE_PERIOD,
	_trans)
	
func _dur_timeout():
	_dur_timer = null
	_phy_timer = null
	if _node != null: _node.position = _prev_node_pos
	shake_finished.emit()
