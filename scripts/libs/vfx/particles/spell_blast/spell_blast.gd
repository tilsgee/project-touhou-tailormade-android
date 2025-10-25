extends GPUParticles2D

var where: Variant = Vector2.ZERO
var alpha := 1.0

func _ready() -> void:
	emitting = true
	modulate.a = alpha
	await get_tree().create_timer(lifetime, false).timeout
	queue_free()

func _physics_process(_delta: float) -> void:
	if where is Vector2:
		global_position = where
	if where is Node:
		global_position = where.global_position
