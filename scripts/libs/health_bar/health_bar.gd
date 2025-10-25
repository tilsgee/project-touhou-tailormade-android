class_name HealthBar extends Control

const META := &"health_bar"

static var _scene: PackedScene = preload("uid://6sk2b2n2863p")

static func create(health_percent: float, node: Node2D, pos_offset := Vector2(0.0, -68.0)) -> HealthBar:
	var instance := _check_instance(node)
	if instance == null:
		instance = _scene.instantiate()
		Game.ui_node.add_child(instance)
		instance.parent = node
		instance.global_position = Game.get_relative_position(node) + pos_offset
		instance.parent.set_meta(META, instance)
	instance.offset = pos_offset
	instance.progress_bar_r.value = health_percent * 100.0
	instance.modulate.a = 1.0
	AutoTween.new(instance, &"modulate:a", 0.0).set_delay(1.0)
	AutoTween.new(instance.progress_bar_o, &"value", health_percent * 100.0, 0.5, Tween.TRANS_LINEAR)
	return instance

static func _check_instance(node: Node2D) -> HealthBar:
	if node.has_meta(META):
		return node.get_meta(META) if node.get_meta(META) != null else null
	return null

@onready var progress_bar_r: ProgressBar = %ProgressBarRed
@onready var progress_bar_o: ProgressBar = %ProgressBarOrange

var parent: Node2D
var offset: Vector2

func _physics_process(_delta: float) -> void:
	if parent == null:
		queue_free()
		set_physics_process(false)
		return
	global_position = Game.get_relative_position(parent) + offset
