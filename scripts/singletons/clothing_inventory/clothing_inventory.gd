extends Node

const INVENTORY_MAX_ITEM := 4

var is_inventory_full:
	get: return held_clothing.size() >= INVENTORY_MAX_ITEM

var held_clothing : Array[ClothingData]


func add_clothing_to_inventory(_c_data : ClothingData):
	held_clothing.append(_c_data)
	
	GameUI.instance.update_clothes(held_clothing)


func remove_clothing_from_inventory(_c_data : ClothingData):
	held_clothing.erase(_c_data)
	
	GameUI.instance.update_clothes(held_clothing)
