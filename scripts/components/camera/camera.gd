class_name Camera extends Camera2D

enum MODE {STATIC, FOLLOW_PLAYER, FOLLOW_NODE}

static var instance: Camera
static var shake_offset: Vector2
static var external_offset: Vector2

static var _current_mode: MODE
static var _follow_node: Node2D

# Magic numbers
const OFFSET := 30.0
const OFFSET_SWAY_SPEED := 1.5
const VERTICAL_OFFSET := -32.0
const FOLLOW_SPEED := 1.0
const VERTICAL_SPEED_DEVIDER := 1.2

var _limit := Vector4.ZERO
var _offset := Vector2.ZERO
var _previous_pixel_snap_delta := Vector2.ZERO
var _current_velocity := Vector2.ZERO
var _current_position := Vector2.ZERO

## Set camera mode, don't set 'current_mode' directly, use this instead
static func set_mode(mode: MODE, target_node: Object = null) -> void:
	match mode:
		MODE.STATIC:
			pass
		MODE.FOLLOW_PLAYER:
			_follow_node = Player.instance
		MODE.FOLLOW_NODE:
			assert(target_node != null, "set_node() to FOLLOW_TARGET requires target_node")
			_follow_node = target_node
	_current_mode = mode

static func force_sync() -> void:
	Camera.instance._current_position = Player.instance.global_position
	Camera.instance._current_velocity = Vector2.ZERO

static func get_mode() -> MODE:
	return _current_mode
	
## Set camera limit
static func set_cam_limit(limit: Vector4, instant: bool = true) -> void:
	if instant: Camera.instance._limit = limit
	else: AutoTween.new(Camera.instance, "_limit", limit, 2.0, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)

func _init() -> void:
	instance = self
	shake_offset = Vector2.ZERO
	if _limit == Vector4.ZERO:
		set_cam_limit(Vector4(-1e4, -1e4, 1e4, 1e4))

func _ready() -> void:
	(func():
		if Player.instance == null:
			return
		global_position = Player.instance.global_position
		_current_position = Player.instance.global_position
	).call_deferred()

func _process(delta):
	if _current_mode != MODE.STATIC:
		_camera_physics(delta)
	if Game.instance != null:
		Game.instance.subpixel_stabilizer(_previous_pixel_snap_delta)

func _camera_physics(delta: float) -> void:
	# Code by:
	# https://github.com/voithos/godot-smooth-pixel-camera-demo
	var next_pos: Vector2
	var snapped_pos: Vector2
	var target_pos := Player.instance.global_position
	var delta_pos_player := Game.get_cursor_position().x - Player.instance.global_position.x
	
	
	if Player.enable_input:
		target_pos += (Game.get_cursor_position() - Player.instance.global_position)/4.0
		_offset.x = lerp(_offset.x, OFFSET * sign(delta_pos_player), delta * OFFSET_SWAY_SPEED)
	
	var res_x := _smooth_damp(_current_position.x, target_pos.x + _offset.x + external_offset.x, _limit.x, _limit.z, _current_velocity.x, 0.2, INF, delta * FOLLOW_SPEED)
	var res_y := _smooth_damp(_current_position.y, target_pos.y + VERTICAL_OFFSET + external_offset.y, _limit.y, _limit.w, _current_velocity.y, 0.2, INF, delta * FOLLOW_SPEED / VERTICAL_SPEED_DEVIDER)
	
	next_pos.x = res_x[0]
	next_pos.y = res_y[0]
	_current_velocity.x = res_x[1]
	_current_velocity.y = res_y[1]
	_current_position = next_pos
	
	snapped_pos = (next_pos + Vector2(0.5, 0.5)).floor()
	_previous_pixel_snap_delta = snapped_pos - next_pos
	next_pos = snapped_pos
	
	global_position = next_pos + shake_offset
	
	force_update_scroll()

func _smooth_damp(current: float, target: float, limit_start: float, limit_end: float, current_velocity: float, smooth_time: float, max_speed: float, delta: float) -> Array[float]:
	# Code by:
	# https://github.com/voithos/godot-smooth-pixel-camera-demo
	smooth_time = max(smooth_time, 0.0001)
	var omega := 2.0 / smooth_time

	var x := omega * delta
	var x_exp := 1.0 / (1.0 + x + 0.48 * x * x + 0.235 * x * x * x)
	var change := current - target
	var original_target := target

	# Clamp max speed.
	var max_change := max_speed * smooth_time
	change = clamp(change, -max_change, max_change)
	target = current - change

	var temp := (current_velocity + omega * change) * delta
	current_velocity = (current_velocity - omega * temp) * x_exp
	var output := target + (change + temp) * x_exp

	# Prevent overshooting.
	if (original_target - current > 0.0) == (output > original_target):
		output = original_target
		current_velocity = (output - original_target) / delta
	if (output <= limit_start) or (output >= limit_end):
		current_velocity = 0.0
		output = limit_start if output <= limit_start else limit_end

	return [output, current_velocity]
