class_name Arena extends Node2D

static var instance: Arena

static var pooled_nodes: Node2D:
	get: return instance.get_node("%PooledNodes")
static var other_nodes: Node2D:
	get: return instance.get_node("%OtherNodes")

func _init() -> void:
	instance = self

func _ready() -> void:
	assert(get_tree().current_scene is Game, "Please run Game scene instead.")
