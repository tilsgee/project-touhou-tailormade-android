@abstract class_name ParticlesGPU extends GPUParticles2D

func _ready() -> void:
	hide()
	emitting = false
	one_shot = true

func _pool_claim() -> void:
	get_tree().create_timer(lifetime).timeout.connect(
		ObjectPoolService.unclaim.bind(self)
	)
	(func():
		restart()
		show()
	).call_deferred()

func _pool_unclaim() -> void:
	hide()
