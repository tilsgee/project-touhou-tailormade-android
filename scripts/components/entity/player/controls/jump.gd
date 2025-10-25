extends Node2D

signal touched_floor
signal jumped

enum TIMER {JUMP, COYOTE, COOLDOWN}

const JUMP_VELOCITY := 137.0
const JUMP_AMPLIFIER := 130.0
const JUMP_DURATION_WAIT_TIME := 0.40
const COYOTE_JUMP_WAIT_TIME := 0.08
const COOLDOWN_WAIT_TIME := 0.15

var is_coyoting: bool:
	get: return _coyote_timer != null

@onready var _ground_clearance: Area2D = %GroundClearance
@onready var _player: Player = owner

var _was_on_floor := false
var _coyote_timer: SceneTreeTimer
var _cooldown_timer: SceneTreeTimer
var _jump_timer: SceneTreeTimer
	
## Public method if you want to jump from another script
func jump() -> void:
	_create_timer(TIMER.JUMP)
	_create_timer(TIMER.COOLDOWN)
	jumped.emit()

func _input(event: InputEvent) -> void:
	if !Player.enable_input:
		return
	if event.is_action_released(&"Jump"):
		_jump_timer = null
		_coyote_timer = null
	if event.is_action_pressed(&"Jump"):
		_do_jump()

func _process(_delta: float) -> void:
	_coyote()
	_touched_floor_signal()
	if !Player.enable_input:
		return
	_jump_process()
	_ceiling_collide()
	
func _do_jump() -> void:
	# Jump Buffer
	var ground_check = _ground_clearance.has_overlapping_bodies()
	if _cooldown_timer != null:
		return
	if _coyote_timer == null:
		if ground_check and !_player.is_on_floor():
			await touched_floor # Wait until _player touches the ground
		# Prevent flying
		if !_player.is_on_floor():
			return
		# Cancel jump when the button is not pressed while still on jump buffer
		if !Input.is_action_pressed(&"Jump"):
			return
		# Prevent overlapped jumps
		if _jump_timer != null:
			return
	# Main jump
	jump()
	
func _jump_process() -> void:
	if _jump_timer != null:
		_player.velocity.y = - JUMP_VELOCITY - (_jump_timer.time_left/JUMP_DURATION_WAIT_TIME * JUMP_AMPLIFIER)
		
func _coyote() -> void:
	if _was_on_floor and !_player.is_on_floor():
		_create_timer(TIMER.COYOTE)

func _ceiling_collide() -> void:
	if _player.is_on_ceiling():
		_player.velocity.y = 0
		_jump_timer = null
		_coyote_timer = null

func _create_timer(type: TIMER) -> void:
	match type:
		TIMER.JUMP:
			_jump_timer = get_tree().create_timer(JUMP_DURATION_WAIT_TIME)
			_jump_timer.timeout.connect(func(): _jump_timer = null, CONNECT_ONE_SHOT)
		TIMER.COYOTE:
			_coyote_timer = get_tree().create_timer(COYOTE_JUMP_WAIT_TIME)
			_coyote_timer.timeout.connect(func(): _coyote_timer = null, CONNECT_ONE_SHOT)
		TIMER.COOLDOWN:
			_cooldown_timer = get_tree().create_timer(COOLDOWN_WAIT_TIME)
			_cooldown_timer.timeout.connect(func(): _cooldown_timer = null, CONNECT_ONE_SHOT)

func _touched_floor_signal() -> void:
	if _player.is_on_floor() and !_was_on_floor:
		touched_floor.emit()
	_was_on_floor = _player.is_on_floor()
