extends Sprite2D

var _offet: Vector2
var _parent: Node2D

func _ready() -> void:
	_offet = position
	reparent.call_deferred(ArenaTailormade.backgrounds)
	_parent = owner
	_parent.tree_exited.connect(queue_free)
	
func _physics_process(_delta: float) -> void:
	if is_instance_valid(_parent):
		global_position = _parent.global_position + _offet
