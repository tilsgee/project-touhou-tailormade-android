class_name ClickableSpriteButton extends Button

signal visually_pressed

const SCALE_UP_FACTOR := 1.06
const SCALE_DOWN_FACTOR := 0.94

@export var _sprite_node : Sprite2D
@export var _sprite_image : Texture

var _scale_tweener : Tween
var _is_during_pressing := false


func _ready() -> void:
	update_sprite_and_size()
	
	mouse_entered.connect(func(): _simple_scale_tween(SCALE_UP_FACTOR))
	mouse_exited.connect(func(): 
		_simple_scale_tween(1.0)
		_is_during_pressing = false
		)
		
	pressed.connect(_on_pressing)


func update_sprite_and_size(_new_texture := Texture.new()):
	if _new_texture != null:
		_sprite_image = _new_texture
	
	if _sprite_node:
		if _sprite_image != null:
			_sprite_node.texture = _sprite_image
			
		var _sprite_tex := _sprite_node.get_texture()
		if _sprite_tex != null:
			self.custom_minimum_size = _sprite_tex.get_size()
	
	
func _on_pressing():
	if _is_during_pressing:
		return
	_is_during_pressing = true
	#print("pressed")
	
	if _sprite_node:
		_init_scale_tweener()
		_scale_tweener.tween_property(	_sprite_node,
										"scale", Vector2.ONE * SCALE_DOWN_FACTOR, 0.1
										).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		_scale_tweener.tween_property(	_sprite_node,
										"scale", Vector2.ONE * 1.0, 0.1
										).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		_scale_tweener.tween_callback(func(): 
			_is_during_pressing = false
			visually_pressed.emit()
			)
	else:
		_is_during_pressing = false
		visually_pressed.emit()


func _simple_scale_tween(_target_scale : float):
	if not _sprite_node:
		return
		
	_init_scale_tweener()
	_scale_tweener.tween_property(	_sprite_node,
									"scale", Vector2.ONE * _target_scale, 0.1
									).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)


func _init_scale_tweener():
	if _scale_tweener:
		if _scale_tweener.is_running():
			_scale_tweener.kill()
			
	_scale_tweener = create_tween()
