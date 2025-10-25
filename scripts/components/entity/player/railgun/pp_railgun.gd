extends Projectile

var trail: Trail

func _pool_claim() -> void:
	super._pool_claim()
	var col := Color.WHITE
	col.a = 1.0
	Trail.new(Arena.other_nodes, self, col, 20.0, 50)
	
func _pool_unclaim() -> void:
	super._pool_unclaim()
	Trail.remove(self, 0.33)
