extends BackBufferCopy

var lifespan := 3.0
var atlas := false
var speed := 10.0
var feather := 0.1
var gap := 0.0
var force := 0.24
var initial_size := 0.0

@onready var _shockwave: ColorRect = $Shockwave

var tracker: Node2D = Node2D.new()

var _force := 0.0
var _expanding := false
var _size: float

func _ready():
	var v_x: float = Game.SCREEN_RES.x
	var rect_size := Vector2(v_x, v_x)

	_shockwave.custom_minimum_size = rect_size
	_size = initial_size
	
	_shockwave.material.set(&"shader_parameter/force", 0.0)
	_shockwave.material.set(&"shader_parameter/preview_atlas", atlas)
	_shockwave.material.set(&"shader_parameter/rect_size", rect_size)
	_shockwave.material.set(&"shader_parameter/feather", feather)
	_shockwave.material.set(&"shader_parameter/gap", gap)

func _physics_process(delta):
	var relative_position := Game.get_relative_position(tracker)

	_shockwave.material.set(&"shader_parameter/position", relative_position)
	_shockwave.material.set(&"shader_parameter/size", _size)
	_shockwave.material.set(&"shader_parameter/force", _force)
	
	_size += delta / (1.0 / speed * 10)
	
	if !_expanding:
		_force += delta * 2.0
		if _force >= force:
			_expanding = true
			_force = force
			
	else:
		_force -= delta/(lifespan)
		if _force <= 0:
			set_process(false)
			tracker.queue_free()
			queue_free()
