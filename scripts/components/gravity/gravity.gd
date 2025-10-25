class_name Gravity extends Node2D

var speed_modifier := 1.0
var active: bool:
	get: return is_physics_processing()
	
static var _gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
static var _movement: GDScript = load("uid://bh2ros8k6g6v5")

func toggle(enabled: bool, reset_velocity := true) -> void:
	if reset_velocity: owner.velocity = Vector2.ZERO
	set_physics_process(enabled)

func _ready() -> void:
	assert(owner is CharacterBody2D, "%s is not CharacterBody2D" % owner)

func _physics_process(delta: float) -> void:
	if !owner.is_on_floor():
		owner.velocity.y += _gravity * speed_modifier * delta
	_cap_to_terminal_velocity()

func _cap_to_terminal_velocity() -> void:
	owner.velocity.y = clamp(owner.velocity.y, -_movement.TERMINAL_VELOCITY, _movement.TERMINAL_VELOCITY)
