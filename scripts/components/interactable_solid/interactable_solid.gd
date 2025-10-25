extends StaticBody2D

const INTERACTABLE_BORDER_SHADERMAT = preload("uid://bkdpfknauvqrh") # inactive at start

@export var _interactable_sprite : Sprite2D

var _new_shadermat_res : ShaderMaterial
var _current_shadermat : ShaderMaterial

var is_selected := false


func _ready() -> void:
	if _interactable_sprite != null:
		_new_shadermat_res = INTERACTABLE_BORDER_SHADERMAT.duplicate()
		_interactable_sprite.material = _new_shadermat_res
		_current_shadermat = _interactable_sprite.material as ShaderMaterial


func selected():
	if _current_shadermat == _new_shadermat_res:
		_current_shadermat.set_shader_parameter("active", true)
	is_selected = true
	
	
func deselect():
	if _current_shadermat == _new_shadermat_res:
		_current_shadermat.set_shader_parameter("active", false)
	is_selected = false
