extends Node

const MIN_VEL := 10.0

enum STATE {IDLE, RUN}
enum FACING {LEFT, RIGHT}

var current_state: STATE
var current_facing: FACING

@onready var _player: Player = owner

func _physics_process(_delta: float) -> void:
	if abs(_player.velocity.x) <= MIN_VEL and abs(_player.velocity.y)  <= MIN_VEL :
		current_state = STATE.IDLE
	else:
		current_state = STATE.RUN
	
	var delta_pos := Cursor.instance.global_position - Game.get_relative_position(_player)

	current_facing = FACING.RIGHT if delta_pos.x > 0 else FACING.LEFT
