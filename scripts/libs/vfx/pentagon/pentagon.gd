@tool extends Node2D

const SEGMENT := 32
const RADIUS := 180.0
const DEVIDER := 5.0
const OUTER_SCALE := 1.4
const FOLLOW_SPEED := 5.0

var follow_node: Node
var kanji_rotation_speed := 2.0
var pentagon_rotation_speed := 1.0
var inner_color := Color.WHITE
var outter_color := Color.WHITE

@onready var _kanji := %Kanji
@onready var _kanji_outer := %KanjiOuter
@onready var _kanji_center := %KanjiCenter
@onready var _pentagon := %Pentagon
@onready var _pentagon_outer := %PentagonOuter
@onready var _center := %Center
@onready var _inner := %Inner
@onready var _outter := %Outter

func destroy() -> void:
	await _anim_out()
	queue_free()

func _ready() -> void:
	var offset_in = _kanji.width / 3.0
	var offset_out = _kanji_outer.width / 3.0
	
	_draw_circle(_kanji, RADIUS)
	_draw_circle(_kanji_outer, RADIUS * OUTER_SCALE)
	_draw_circle(_kanji_center, RADIUS / 3.3, roundi(SEGMENT / 3.3))
	
	_draw_pentagon(_pentagon, RADIUS - offset_in)
	_draw_pentagon(_pentagon_outer, (RADIUS * OUTER_SCALE) - offset_out, false)
	
	_pentagon.modulate.a = 0.5
	_kanji.modulate.a = 0.5
	
	_kanji_outer.modulate.a = 0.2
	_pentagon_outer.modulate.a = 0.2
	
	_kanji_center.modulate.a = 0.5
	
	_inner.modulate = inner_color
	_outter.modulate = outter_color
	_center.modulate = inner_color * 1.3
	
	_anim_in()

func _physics_process(delta: float) -> void:
	if follow_node != null:
		_center.global_position = lerp(_center.global_position, follow_node.global_position, delta * FOLLOW_SPEED * 4.0)
		_inner.global_position = lerp(_inner.global_position, follow_node.global_position, delta * FOLLOW_SPEED * 1.5)
		_outter.global_position = lerp(_outter.global_position, follow_node.global_position, delta * FOLLOW_SPEED)
		
	_kanji.global_rotation += wrapf(delta * kanji_rotation_speed / DEVIDER, 0.0, PI * 2.0)
	_pentagon.global_rotation += wrapf(delta * pentagon_rotation_speed / DEVIDER, 0.0, PI * 2.0)

	_kanji_outer.global_rotation -= wrapf(delta * kanji_rotation_speed / DEVIDER, 0.0, PI * 2.0)
	_pentagon_outer.global_rotation -= wrapf(delta * pentagon_rotation_speed / DEVIDER, 0.0, PI * 2.0)
	_kanji_center.global_rotation -= wrapf(delta * kanji_rotation_speed / DEVIDER * 3.0, 0.0, PI * 2.0)
	
func _anim_in() -> void:
	_inner.global_position = follow_node.global_position
	_outter.global_position = follow_node.global_position
	
	AutoTween.new(self, &"modulate:a", 1.0, 0.5).from(0.0)
	AutoTween.new(_center, &"scale", Vector2.ONE, 1.0).from(Vector2(0.3, 0.3))
	AutoTween.new(_inner, &"scale", Vector2.ONE, 1.0).from(Vector2(1.5, 1.5))
	await AutoTween.new(_outter, &"scale", Vector2.ONE, 1.0).from(Vector2(2.5, 2.5)).finished

func _anim_out() -> void:
	AutoTween.new(self, &"modulate:a", 0.0, 0.7, Tween.TRANS_QUART, Tween.EASE_IN).from(1.0)
	AutoTween.new(_inner, &"scale", Vector2(1.5, 1.5), 1.0, Tween.TRANS_QUART, Tween.EASE_IN)
	AutoTween.new(_center, &"scale", Vector2(0.3, 0.3), 1.0, Tween.TRANS_QUART, Tween.EASE_IN)
	await AutoTween.new(_outter, &"scale", Vector2(2.5, 2.5), 1.0, Tween.TRANS_QUART, Tween.EASE_IN).finished

func _draw_pentagon(line: Line2D, radius: float, star_shape := true) -> void:
	const ANGLE = 72.0
	var pentagon := [Vector2(0.0, -radius)]
	for i in range(5):
		var new_dot = pentagon[-1].rotated(deg_to_rad(ANGLE))
		pentagon.append(new_dot)
	var star := []
	for i in range(0, 10, 2):
		var index = wrapi(i, 0, pentagon.size() - 1)
		star.append(pentagon[index])
	line.points = star if star_shape else pentagon
	
func _draw_circle(line: Line2D, radius: float, segments := SEGMENT) -> void:
	var coord: PackedVector2Array
	for i in range(segments):
		var x = remap(i, 0, segments, - radius, radius)
		var y = sqrt((radius * radius) - (x * x))
		coord.append(Vector2(x,y))
		coord.append(Vector2(x,-y))
		
	for i in range(segments):
		var y = remap(i, 0, segments, -radius, radius)
		var x = sqrt((radius * radius) - (y * y))
		coord.append(Vector2(x,y))
		coord.append(Vector2(-x,y))
		
	coord = Geometry2D.convex_hull(coord)
	(func():
		line.points = coord
	).call_deferred()
