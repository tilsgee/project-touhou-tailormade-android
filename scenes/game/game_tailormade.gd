extends Game


## Turns node's position inside 'Level' node into screen position (This is for nodes outside the 'Level', usually for UI)
static func get_relative_position(node: Node) -> Vector2:
	var offset: Vector2 = abs(scaling - default_scaling) * gameview.get_rect().size / 2
	if node == null: return Vector2.ZERO
	return (node.get_global_transform_with_canvas().origin * scaling) - (PIXEL_OFFSET / 2) + subpixel_offset - offset

static func get_cursor_position() -> Vector2:
	var offset: Vector2 = abs(scaling - default_scaling) * gameview.get_rect().size / 2
	var res := (viewport.get_mouse_position() / scaling) + (PIXEL_OFFSET / 2) - (gameview.get_rect().size / 2) - subpixel_offset + offset
	if Camera.instance != null:
		res += Camera.instance.global_position
	return res
	
static func game_over() -> void:
	await Game.instance.get_tree().create_timer(0.5).timeout
	print("GAME OVER")
	Game.instance.get_tree().paused = true
	
func subpixel_stabilizer(previous_pixel_snap_delta: Vector2) -> void:
	subpixel_offset = previous_pixel_snap_delta * Game.scaling
	gameview.global_position = subpixel_offset
	gameview.global_position -= PIXEL_OFFSET / 2
	gameview.global_position += gameview.get_rect().size

func _init() -> void:
	instance = self

func _ready() -> void:
	get_tree().paused = false
	_update_viewport()
	var init_vol = %BGM.volume_db
	AutoTween.new(%BGM, "volume_db", init_vol, 1.0, Tween.TRANS_LINEAR).from(-64.0)
	%BGM.play.call_deferred()
	
func _input(event: InputEvent) -> void:
	viewport.push_input(event)
	
func _update_viewport() -> void:
	default_scaling = SCREEN_RES / GAME_RES
	viewport.size = GAME_RES + PIXEL_OFFSET
	gameview.scale = default_scaling	
