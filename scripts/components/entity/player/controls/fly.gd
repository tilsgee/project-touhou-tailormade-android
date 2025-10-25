extends Node2D

const SPEED := 330.0
const MULT := 2e2
const ACCEL := 2.0

var active := false

@onready var _player: Player = owner
@onready var _gravity_node := %Gravity
@onready var _movement_node := %Movement
@onready var _jump_node := %Jump
@onready var _ground_clearance := %GroundClearance

var _max_energy: float:
	set(val): Stats.set_stats(&"hover", &"max_value", val)
	get: return Stats.get_stats(&"hover", &"max_value")

var _energy: float= Stats.get_stats(&"hover", &"value"):
	set(val):
		var r := clampf(val, 0.0, _max_energy)
		Stats.set_stats(&"hover", &"value", r)
		if r == 0.0:
			Stats.send_notification(&"hover_depleted")
		if r == _max_energy:
			Stats.send_notification(&"hover_full")
			set_physics_process(false)
	get:
		return Stats.get_stats(&"hover", &"value")

func toggle_active(b: bool) -> void:
	active = b
	_gravity_node.toggle(!b, false)
	_movement_node.disabled = b
	if b:
		Camera.external_offset.y = -Camera.VERTICAL_OFFSET
		set_physics_process(true)
		var t := Trail.new(Arena.other_nodes, self)
		t.z_index = -1
	else:
		Camera.external_offset.y = 0.0
		Trail.remove(self)

func _ready() -> void:
	Stats.stats_notification.connect(func(w, _v):
		if w == &"hover_depleted":
			toggle_active(false)
		if w == &"hover_full":
			pass
	)
	_jump_node.touched_floor.connect(toggle_active.bind(false))

func _input(event: InputEvent) -> void:
	if _player.is_on_floor():
		return
	if _jump_node.is_coyoting:
		return
	if _ground_clearance.has_overlapping_bodies() and _player.velocity.y >= 0.0 and !active:
		return
	if event.is_action_pressed(&"Jump"):
		toggle_active(!active)

func _process(delta: float) -> void:
	if active:
		_move_on_air(delta)
	
func _physics_process(_delta: float) -> void:
	if !active: _energy += 0.1
	else: _energy -= 0.2

func _move_on_air(delta: float) -> void:
	var delta_pos_player := Game.get_cursor_position().x - Player.instance.global_position.x
	var dir := Vector2(
		Input.get_axis(&"ui_left", &"ui_right"),
		Input.get_axis(&"ui_up", &"ui_down")
	)
	var slowdown = 1.0 if dir.x == sign(delta_pos_player) else 0.8
	_player.velocity = lerp(_player.velocity, dir * SPEED * slowdown, delta * ACCEL)
