class_name AutoTween extends RefCounted

## Automatically manage tween for you,
## No manual killing, no manual transition and ease settings,
## Just tween something and it will be done without hasle.

# AutoTween my beloved
# The saviour of Tweens

signal finished

const META := &"auto_tween"

var tween: Tween
var tweener: Tweener

## Kill active tween of 'property' inside the 'node'
static func kill(node: Node, property: Variant) -> void:
	var hashed := _get_hash(property)
	var unfreed_at: AutoTween
	if !node.has_meta(hashed):
		return
	unfreed_at = node.get_meta(hashed)
	unfreed_at.tween.kill()
	unfreed_at.tween = null
	unfreed_at.tweener = null
	node.remove_meta(hashed)

## Kill all active tween inside the 'node'
static func kill_all(node: Node) -> void:
	for g in node.get_meta_list():
		if !g.contains(META):
			continue
		var unfreed_at: AutoTween = node.get_meta(g)
		if unfreed_at == null:
			continue
		unfreed_at.tween.kill()
		unfreed_at.tween = null
		unfreed_at.tweener = null
		node.remove_meta(g)

## Check if 'node' has tween of 'property' 
static func has_tween(node: Node, property: Variant) -> bool:
	var hashed := _get_hash(property)
	return node.has_meta(hashed)

## Ignnore engine time scale, no slowdown of animation on slowmo mode
func ignore_engine_time() -> AutoTween:
	if tween != null:
		tween.set_ignore_time_scale(true)
	return self
	
## Ignnore pause when the tree is paused
func ignore_pause() -> AutoTween:
	if tween != null:
		tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	return self

## Set delay before tweening
func set_delay(delay: float) -> AutoTween:
	if tweener != null:
		tweener.set_delay(delay)
	return self

## Tween from
func from(val: Variant) -> AutoTween:
	if tweener != null and tweener is PropertyTweener:
		tweener.from(val)
	return self

## Tween from current
func from_current() -> AutoTween:
	if tweener != null and tweener is PropertyTweener:
		tweener.from_current()
	return self

## Tween as relative
func as_relative() -> AutoTween:
	if tweener != null and tweener is PropertyTweener:
		tweener.as_relative()
	return self

## Easily create tween
func _init(
		node: Node,
		property: String,
		final_val: Variant,
		dur := 0.75,
		trans := Tween.TRANS_QUART,
		ease_mode := Tween.EASE_OUT
	) -> void:
	kill(node, property)
	_tween(node, property, final_val, dur, trans, ease_mode)

func _tween(node: Node, property, final_val, dur, trans, ease_mode) -> void:
	if _is_node_invalid(node):
		tween = null
		tweener = null
		return
	if tween == null:
		tween = node.get_tree().create_tween()
	var hashed := _get_hash(property)
	tween.set_ease(ease_mode).set_trans(trans)
	tweener = tween.tween_property(node, property, final_val, dur)
	tween.set_parallel()
	tween.finished.connect(_tween_finished.bind(node, hashed))
	node.set_meta(hashed, self)

class Method extends AutoTween:
	## Easily create callback tween,
	## Useful for modifying preperty outside a Node
	## Callable can be lambda
	func _init(
		parent_scene: Node,
		callable: Callable,
		from_val: Variant,
		to_val: Variant,
		dur := 0.75,
		trans := Tween.TRANS_QUART,
		ease_mode := Tween.EASE_OUT
	) -> void:
		kill(parent_scene, callable)
		_tween_method(parent_scene, callable, from_val, to_val, dur, trans, ease_mode)

	func _tween_method(parent_scene, callable, from_val, to_val, dur, trans, ease_mode) -> void:
		if tween == null:
			tween = parent_scene.create_tween()
		var hashed := _get_hash(callable)
		tween.set_ease(ease_mode).set_trans(trans)
		tweener = tween.tween_method(callable, from_val, to_val, dur)
		tween.set_parallel()
		tween.finished.connect(_tween_finished.bind(parent_scene, hashed))
		parent_scene.set_meta(hashed, self)

static func _get_hash(property: Variant) -> String:
	return META + str(property.hash()) if property is String else META + str(abs(property.get_object_id()))

func _tween_finished(node: Variant, hashed: String) -> void:
	finished.emit()
	if !_is_node_invalid(node):
		node.remove_meta(hashed)
	tween = null
	tweener = null

func _is_node_invalid(node: Variant) -> bool:
	return node == null or node.is_queued_for_deletion() or !node.is_inside_tree()
