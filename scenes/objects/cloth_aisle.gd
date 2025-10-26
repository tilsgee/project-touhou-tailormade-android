class_name ClothAisle extends Node2D

signal open_cloth_aisle(list : Array[ClothingData])

@export var clothing_list : Array[ClothingData]


func _on_interactable_solid_player_interacted() -> void:
	open_cloth_aisle.emit(clothing_list)
