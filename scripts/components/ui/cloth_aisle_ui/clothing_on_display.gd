class_name ClothingOnDisplay extends ClickableSpriteButton

signal selected_clothing(data : ClothingData)

var clothing_data : ClothingData


func _ready() -> void:
	super._ready()
	visually_pressed.connect(func(): selected_clothing.emit(clothing_data))
	
