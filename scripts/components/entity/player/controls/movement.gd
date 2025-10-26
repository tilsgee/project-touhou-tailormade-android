extends Node2D

const SPEED := 150.0
const TERMINAL_VELOCITY := 300.0
const DELTA_MULTIPLIER := 15.0

@onready var _player: Player = owner

var disabled := false
var direction: Vector2i
var slowdown := false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"Slowdown"):
		slowdown = true
	if event.is_action_released(&"Slowdown"):
		slowdown = false
	if Player.enable_input:
		direction.x = Input.get_axis(&"ui_left", &"ui_right") as int
		direction.y = Input.get_axis(&"ui_up", &"ui_down") as int
	else:
		direction = Vector2.ZERO
		
func _process(delta: float) -> void:
	if disabled:
		return
	if !Player.enable_input:
		_player.velocity = Vector2.ZERO
		return
	_run(delta)
	_cap_to_terminal_velocity()

func _run(delta: float) -> void:
	if !Player.enable_input:
		direction = Vector2.ZERO
	_player.velocity = lerp(
		_player.velocity,
		(direction * SPEED) if !slowdown else (direction * SPEED * 0.5),
		delta * DELTA_MULTIPLIER
	)

func _cap_to_terminal_velocity() -> void:
	_player.velocity = Vector2(
		clamp(_player.velocity.x, -TERMINAL_VELOCITY, TERMINAL_VELOCITY),
		clamp(_player.velocity.y, -TERMINAL_VELOCITY, TERMINAL_VELOCITY)
	)
