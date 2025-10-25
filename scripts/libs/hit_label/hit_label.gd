class_name HitLabel extends Control

const META := &"hitlabel"

static var _scene: PackedScene = preload("uid://bp6k0giylx3f3")

static func create(damage_ammount: float, node: Node, pos_offset := Vector2(0.0, -118.0)) -> HitLabel:
	var instance := _check_instance(node)
	if instance == null:
		instance = _scene.instantiate()
		Arena.other_nodes.add_child(instance.post_marker)
		Game.ui_node.add_child(instance)
		instance.parent = node
		instance.global_position = Game.get_relative_position(node) + pos_offset
		instance.parent.set_meta(META, instance)
	instance.offset = pos_offset
	instance.damage = damage_ammount
	instance.accumulated_damage += damage_ammount
	instance.label.position.y = 0.0
	instance.post_marker.global_position = node.global_position
	AutoTween.new(instance, &"modulate:a", 0.5).from(1.0)
	AutoTween.new(instance.label_container, &"position:y", -24.0).from(0.0)
	AutoTween.new(instance.label, &"position:y", -42.0, 0.75, Tween.TRANS_QUART, Tween.EASE_IN).set_delay(1.0).finished.connect(instance.queue_free)
	return instance

static func _check_instance(node: Node2D) -> HitLabel:
	if node.has_meta(META):
		return node.get_meta(META) if node.get_meta(META) != null else null
	return null

@onready var label_container := %LabelContainer
@onready var label := %Label

var offset: Vector2
var damage: float
var accumulated_damage: float
var parent: Node
var post_marker := Node2D.new()

func _ready() -> void:
	tree_exited.connect(post_marker.queue_free)

func _physics_process(_delta: float) -> void:
	global_position = Game.get_relative_position(parent if parent != null else post_marker) + offset
	label.text = "%s%d" % ["+" if sign(accumulated_damage) > 0 else "-", abs(roundi(accumulated_damage))]
	
