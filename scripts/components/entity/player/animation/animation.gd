extends Node2D

@onready var _state := %State
@onready var _anim := $AnimationPlayer
@onready var _model := $AnimatedSprite2D

func _physics_process(_delta: float) -> void:
	match _state.current_state:
		_state.STATE.IDLE:
			_anim.play("idle")
		_state.STATE.RUN:
			_anim.play("run")
	match _state.current_facing:
		_state.FACING.LEFT:
			_model.flip_h = true
		_state.FACING.RIGHT:
			_model.flip_h = false
