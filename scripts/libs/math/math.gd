class_name Math extends RefCounted

static func reflection(incident: Vector2, normal: Vector2) -> Vector2:
	var d := incident
	var n := normal
	# r = d - (2(d ∙ n) * n)
	return d - (2 * (d.dot(n)) * n)
