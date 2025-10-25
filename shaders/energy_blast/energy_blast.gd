extends ColorRect

var follow_node: Node
var target_pos: Vector2
var gradient: GradientTexture1D

func _ready() -> void:
	_set_prop(&"shader_parameter/noise_strength", 0.1, 0.5)
	_set_prop(&"shader_parameter/gap", 0.5, 0.0)
	if gradient != null:
		material.set(&"shader_parameter/gradient_texture", gradient)
	await _set_prop(&"shader_parameter/size", 0.0, 0.2)
	queue_free()

func _set_prop(what: StringName, from: float, to: float, duration: float = 1.2) -> void:
	await create_tween().tween_method(func(val):
		material.set(what, val),
		from, to, duration
	).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART).finished

func _physics_process(_delta: float) -> void:
	if follow_node != null:
		target_pos = follow_node.global_position
	global_position = _calc_pos(target_pos)

func _calc_pos(vec: Vector2) -> Vector2:
	var rect_size := get_rect().size
	var offset := rect_size / 2.0

	return vec - offset
