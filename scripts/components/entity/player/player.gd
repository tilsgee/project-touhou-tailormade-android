class_name Player extends Entity

static var instance: Player
static var enable_input: bool

@onready var state := %State

@onready var _behaviour := %Behaviour

func _init() -> void:
	instance = self
	enable_input = true
	knockback_factor = 300.0
	Camera.set_mode(Camera.MODE.FOLLOW_PLAYER)

func _process(_delta: float) -> void:
	move_and_slide()

func die() -> void:
	_behaviour.die()
	died.emit()

func damage(args: Dictionary) -> void:
	_behaviour.damage(args)
	damaged.emit()
