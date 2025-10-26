class_name ClothingOnDisplay extends ClickableSpriteButton

signal selected_clothing(data : ClothingData)

@onready var _picked_label: Label = %PickedLabel

var clothing_data : ClothingData


func _ready() -> void:
	super._ready()
	_picked_label.hide()
	#new_texture_updated.connect(func():
		#picked_gray_rect.size = self.custom_minimum_size
		#picked_gray_rect.set_anchors_preset(Control.PRESET_CENTER)
	#)
	visually_pressed.connect(func(): selected_clothing.emit(clothing_data))


func dim_this_display():
	#_is_pressable = false
	_sprite_node.self_modulate.v = 0.5
	_picked_label.show()
