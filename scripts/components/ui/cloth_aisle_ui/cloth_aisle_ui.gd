class_name ClothAisleUI extends Panel

const CLOTHING_ON_DISPLAY := preload("uid://cjk1v0j44yjpo")

static var _clothes_hbox: HBoxContainer:
	get: return instance.get_node("%ClothesHbox")

static var instance: ClothAisleUI


static func show_ui(_clothing_list : Array[ClothingData]):
	if instance.visible:
		return
	
	for n in _clothes_hbox.get_children():
		n.queue_free()
	
	for _clothing : ClothingData in _clothing_list:
		var new_display : ClothingOnDisplay = CLOTHING_ON_DISPLAY.instantiate()
		_clothes_hbox.add_child(new_display)
		new_display.update_sprite_and_size(_clothing.cloth_texture)
		new_display.clothing_data = _clothing
		if new_display.clothing_data.is_picked_by_player:
			new_display.dim_this_display()
		new_display.selected_clothing.connect(selected_clothing_and_close_ui)
		
	instance.show()
	Player.enable_input = false
	Camera.set_mode(Camera.MODE.STATIC)


static func selected_clothing_and_close_ui(_c_data : ClothingData):
	if _c_data.is_picked_by_player:
		_c_data.is_picked_by_player = false
		ClothingInventory.remove_clothing_from_inventory(_c_data)
	else:
		_c_data.is_picked_by_player = true
		ClothingInventory.add_clothing_to_inventory(_c_data)
		#print("selected clothing: %s" % _c_data.cloth_identifier)
	hide_ui_and_restore_state()
	
	
static func cancel():
	hide_ui_and_restore_state()


static func hide_ui_and_restore_state():
	instance.hide()
	Player.enable_input = true
	Camera.set_mode(Camera.MODE.FOLLOW_PLAYER)


func _init() -> void:
	instance = self
	
	
func _ready() -> void:
	hide()
