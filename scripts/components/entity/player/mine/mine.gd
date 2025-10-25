extends Projectile

var trail: Trail
static var grad := preload("uid://kx4th63idgu7")

func behaviour(delta: float) -> void: # Can be overwritten
	var a = deg_to_rad(time) + PI/2
	var sig = 1 if index % 2 == 0 else -1
	var distance = speed * delta
	var distance_y = speed * delta * sqrt(a) * sig / 3.0
	var motion = (transform.x * distance) + (transform.y * distance_y)
	position += motion
	rotation = motion.angle()
	
func _pool_claim() -> void:
	super._pool_claim()
	var col := Color.BISQUE
	col.a = 0.3
	Trail.new(Arena.other_nodes, self, col, 10.0, 50).gradient = grad.gradient
	
func _pool_unclaim() -> void:
	super._pool_unclaim()
	Trail.remove(self, 0.33)
