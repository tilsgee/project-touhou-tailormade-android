extends Node

func _ready() -> void:
	AutoTween.new(owner.gameview, &"modulate", Color.WHITE, 1.0, Tween.TRANS_LINEAR).from(Color.BLACK)
