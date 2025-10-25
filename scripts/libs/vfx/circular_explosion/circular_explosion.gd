extends Node2D

var thiccness := 45.0
var duration := 0.5
var color := Color.WHITE

var _radius: float = 0.0
var _thickness: float:
	set(val): _thickness = clampf(val, 0.0, INF)

func _ready() -> void:
	hide()

func _pool_claim() -> void:
	_enable.call_deferred()

func _pool_unclaim() -> void:
	hide()
	
func _draw() -> void:
	draw_circle(Vector2.ZERO, _radius, color, false, _thickness)

func _enable() -> void:
	global_rotation = randf_range(-PI, PI)
	scale = Vector2.ONE * 1.5
	AutoTween.Method.new(self, func(val):
		_radius = val
		_thickness = (thiccness - val)/5.0
		queue_redraw()
	, 0.0, thiccness, duration).finished.connect(ObjectPoolService.unclaim.bind(self))
	show()
	
