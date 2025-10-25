extends BackBufferCopy

var atlas: bool
var speed: float
var thiccness: float
var initial_size: float
var lifetime: float = 3.0

@onready var _explosion: ColorRect = $ExplosionInvert

var tracker: Node2D = Node2D.new()

var _size: float

func _ready():
	var v_x: float = Game.SCREEN_RES.x
	var rect_size := Vector2(v_x, v_x)

	_explosion.custom_minimum_size = rect_size
	_size = initial_size
	_explosion.material.set(&"shader_parameter/preview_atlas", atlas)
	_explosion.material.set(&"shader_parameter/rect_size", rect_size)
	_update_shaders()
	get_tree().create_timer(lifetime, false).timeout.connect(func():
		if !is_queued_for_deletion():
			queue_free()
	)
	
func _physics_process(delta):
	_update_shaders(Game.get_relative_position(tracker))
	
	_size += delta * speed

	thiccness -= delta * (speed / 20.0)
	if thiccness <= 0:
		set_process(false)
		tracker.queue_free()
		queue_free()
		
func _update_shaders(relative_position = null) -> void:
	if relative_position != null:
		_explosion.material.set(&"shader_parameter/position", relative_position)
	_explosion.material.set(&"shader_parameter/size", _size)
	_explosion.material.set(&"shader_parameter/gap", thiccness)
