class_name ClothAisle extends Node2D

signal open_cloth_aisle(list : Array[ClothingData])

@export var aisle_name : String = "Clothing Aisle #0"
@export var clothing_list : Array[ClothingData]
@export var _sprite_node : Sprite2D

var middle_pos : Vector2:
	get:
		if _sprite_node and _sprite_node.texture != null:
			return self.global_position + (_sprite_node.texture.get_size() / 2)
		else:
			return self.global_position


func _on_interactable_solid_player_interacted() -> void:
	var _aisle_data := {
		"name" = aisle_name
	}
	open_cloth_aisle.emit(_aisle_data, clothing_list)
