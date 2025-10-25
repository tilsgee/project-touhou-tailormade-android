class_name HitFlash extends RefCounted

static var _material := preload("uid://jiij57flia05")

var _node: Node2D
var _old_mat: Material

func _init(node: Node2D, max_modulation := 1.0, modulation_color := Color.RED, duration := 0.2) -> void:
	_node = node
	
	if _node.material != null and _node.material != _material:
		_old_mat = _node.material
	_node.material = _material

	var mat := _node.material as ShaderMaterial
	
	mat.set_shader_parameter(&"modulation_color", modulation_color)
	
	AutoTween.Method.new(node, func(val):
		mat.set_shader_parameter(&"max_modulation", val),
		max_modulation, 0.0, duration, Tween.TRANS_LINEAR
	).finished.connect(_remove)

func _remove() -> void:
	if _old_mat != null:
		_node.material = _old_mat
	else:
		_node.material = null
