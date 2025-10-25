extends Projectile

static var grad := preload("uid://kx4th63idgu7")

@onready var _txtr: ColorRect = $ColorRect

func behaviour(delta: float) -> void: # Can be overwritten
	var a = deg_to_rad(time) + PI/2
	var sig = 1 if index % 2 == 0 else -1
	var distance = speed * delta
	var distance_y = speed * delta * sin(a) * sig / 2.0
	var motion = (transform.x * distance) + (transform.y * distance_y)
	position += motion
	_txtr.rotation = motion.angle() - global_rotation
	
func _pool_claim() -> void:
	super._pool_claim()
	var trail := Trail.new(Arena.other_nodes, self, Color.WHITE, 10.0, 50)
	trail.gradient = grad.gradient
	trail.modulate.a = 0.5
	
func _pool_unclaim() -> void:
	super._pool_unclaim()
	Trail.remove(self, 0.33)
