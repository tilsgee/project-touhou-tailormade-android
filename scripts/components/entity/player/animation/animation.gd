extends Node2D

@onready var _state := %State
@onready var _anim := $AnimationTree
@onready var _model := $AnimatedSprite2D
@onready var _state_machine: AnimationNodeStateMachinePlayback = _anim["parameters/StateMachine/playback"]

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Slowdown"):
		_anim.set("parameters/TimeScale/scale", 0.8)
	elif event.is_action_released("Slowdown"):
		_anim.set("parameters/TimeScale/scale", 1.2)

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
