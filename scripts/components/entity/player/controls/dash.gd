extends Node2D

@export var ghost_ammount := 6
@export var duration := 0.2
@export var cooldown := 2.0

@onready var _player: Player = owner
@onready var _sprite: Node2D = %Icon
@onready var _fly_control: Node2D = %Fly
@onready var _gravity_node := %Gravity

var _dash_value: float:
	set(val):
		var res := clampf(val, 0.0, _dash_max_value)
		if res == _dash_max_value and val <= _dash_max_value:
			Stats.send_notification(&"dash_full")
		Stats.set_stats(&"dash", &"value", res)
	get: return Stats.get_stats(&"dash", &"value")

var _dash_max_value: float:
	set(val): Stats.set_stats(&"dash", &"max_value", val)
	get: return Stats.get_stats(&"dash", &"max_value")

var _dir: float:
	get: return Input.get_axis(&"ui_left", &"ui_right")
	
var _active := false:
	set(val):
		if _active == val:
			return
		_active = val
		if !_active:
			AutoTween.new(self, &"_dash_value", _dash_max_value, cooldown, Tween.TRANS_LINEAR).set_delay(duration / 2.0)
			return
		AutoTween.new(self, &"_dash_value", 0.0, duration)
		for i in range(ghost_ammount):
			var new_s := _sprite.duplicate()
			Arena.other_nodes.add_child(new_s)
			new_s.global_position = global_position
			AutoTween.new(new_s, &"modulate:a", 0.0, 0.5).from(1.0).finished.connect(new_s.queue_free)
			await get_tree().create_timer(duration / ghost_ammount).timeout

func _input(event: InputEvent) -> void:
	if _fly_control.active:
		return
	if _dir == 0:
		return
	if _dash_value != _dash_max_value:
		return
	if event.is_action_pressed(&"Dash"):
		_dash()

func _ready() -> void:
	(func(): _dash_value = _dash_max_value).call_deferred()

func _dash() -> void:
	AutoTween.Method.new(self, func(_n):
		_gravity_node.toggle(false, false)
		_player.velocity = Vector2(_dir * 800.0, 0.0)
		_active = true,
		
		null, null, duration
	).finished.connect(func():
		_gravity_node.toggle(true)
		_active = false
	)
