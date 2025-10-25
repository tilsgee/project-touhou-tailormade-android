extends Node2D

const SPEED := 230.0
const TERMINAL_VELOCITY := 500.0
const DRAG := 1.5
const DRAG_ON_AIR := 2.5
const MULT := 3000.0

@onready var _player: Player = owner

var disabled := false
var direction: int

func _input(_event: InputEvent) -> void:
	if Player.enable_input:
		direction = Input.get_axis(&"ui_left", &"ui_right") as int
	else:
		direction = 0
		
func _process(delta: float) -> void:
	if disabled:
		return
	if !Player.enable_input:
		_player.velocity = Vector2.ZERO
		return
	_run(delta)
	_cap_to_terminal_velocity()

func _run(delta: float) -> void:
	var devider: float = DRAG if _player.is_on_floor() else DRAG_ON_AIR
	var delta_pos_player := Game.get_cursor_position().x - Player.instance.global_position.x
	var slowdown = 1.0 if direction == sign(delta_pos_player) else 0.7
	
	if !Player.enable_input:
		direction = 0
	_player.velocity.x = move_toward(
		_player.velocity.x,
		direction * SPEED * slowdown,
		delta * MULT / devider
	)

func _cap_to_terminal_velocity() -> void:
	_player.velocity = Vector2(
		clamp(_player.velocity.x, -TERMINAL_VELOCITY, TERMINAL_VELOCITY),
		clamp(_player.velocity.y, -TERMINAL_VELOCITY, TERMINAL_VELOCITY)
	)
