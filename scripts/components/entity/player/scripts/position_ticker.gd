extends Node

const TICK := 2.0

@onready var _player: Player = owner

var last_valid_position: Vector2

func _ready() -> void:
	last_valid_position = _player.global_position
	_tick()

func _tick() -> void:
	get_tree().create_timer(TICK, false).timeout.connect(func():
		last_valid_position = _player.global_position
		_tick()
	)
