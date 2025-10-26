class_name ClothAisle extends Node2D

signal open_cloth_aisle(list : Array[ClothingData])

@export var clothing_list : Array[ClothingData]
@export var _sprite_node : Sprite2D

var middle_pos : Vector2:
	get:
		if _sprite_node and _sprite_node.texture != null:
			return self.global_position + (_sprite_node.texture.get_size() / 2)
		else:
			return self.global_position

func _on_interactable_solid_player_interacted() -> void:
	open_cloth_aisle.emit(clothing_list)
