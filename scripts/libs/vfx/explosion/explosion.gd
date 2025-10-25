extends AnimatedSprite2D

func _ready() -> void:
	hide()
	animation_finished.connect(ObjectPoolService.unclaim.bind(self))

func _pool_claim() -> void:
	show()
	play(&"main")

func _pool_unclaim() -> void:
	hide()
