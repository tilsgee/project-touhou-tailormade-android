extends Node

const MAX_ENEMY := 5
const SPAWN_DUR := Vector2(2.0, 5.0)

var enemy_arr: Array[Enemy]

func _ready() -> void:
	_spawn_enemy()
	
func _spawn_enemy() -> void:
	get_tree().create_timer(randf_range(SPAWN_DUR.x, SPAWN_DUR.y)).timeout.connect(_spawn_enemy)
	if enemy_arr.size() >= MAX_ENEMY:
		return
	var instance: Enemy = load("uid://gfdqvqd8287m").instantiate()
	owner.add_child.call_deferred(instance)
	instance.global_position.x = randf_range(-200.0, 200.0)
	
	enemy_arr.append(instance)
	instance.tree_exited.connect(enemy_arr.erase.bind(instance))
