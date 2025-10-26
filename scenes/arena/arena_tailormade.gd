extends Arena

@onready var clothes: Node2D = %Clothes


func _ready() -> void:
	super._ready()
	for n in clothes.get_children():
		if n is not ClothAisle:
			continue
		
		n = n as ClothAisle
		n.open_cloth_aisle.connect(ClothAisleUI.show_ui)
	Camera.set_cam_limit(Vector4(
		240.0, 120.0,
		720.0, 420.0
	))
