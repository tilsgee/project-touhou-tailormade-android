extends Node2D

@onready var _state := %State
@onready var _anim := $AnimationTree
@onready var _model := $AnimatedSprite2D
@onready var _state_machine: AnimationNodeStateMachinePlayback = _anim["parameters/playback"] if _anim != null else null

func _physics_process(_delta: float) -> void:
	match _state.current_state:
		_state.STATE.IDLE:
			_state_machine.travel("idle")
		_state.STATE.RUN:
			_state_machine.travel("run")
	match _state.current_facing:
		_state.FACING.LEFT:
			_model.flip_h = true
		_state.FACING.RIGHT:
			_model.flip_h = false
