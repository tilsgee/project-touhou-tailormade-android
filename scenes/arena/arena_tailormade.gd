class_name ArenaTailormade extends Arena

#@onready var clothes: Node2D = %Clothes

static var clothes_node: Node2D:
	get: return instance.get_node("%Clothes")


func _ready() -> void:
	super._ready()
	for n in clothes_node.get_children():
		if n is not ClothAisle:
			continue
		
		n = n as ClothAisle
		n.open_cloth_aisle.connect(ClothAisleUI.show_ui)
