extends Sprite2D

var _offet: Vector2

func _ready() -> void:
	_offet = position
	reparent.call_deferred(ArenaTailormade.backgrounds)
	
func _physics_process(_delta: float) -> void:
	global_position = Player.instance.global_position + _offet
