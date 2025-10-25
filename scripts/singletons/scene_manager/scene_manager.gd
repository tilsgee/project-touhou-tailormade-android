extends Node

signal half_finished
signal finished

var is_transitioning := false

#var loading_screen_path := preload("res://scripts/scene_manager/loading_screen.tscn")
var transition_path := preload("res://scripts/singletons/scene_manager/utils/transition.tscn")

func change_scene(target_scene: PackedScene, instant := false, horizontal := false, invert := false, circular := false, delay := 0.01) -> void:
	var path := target_scene.get_path()
	var old_scene := get_tree().current_scene.get_path()
	
	if instant:
		var _res = get_tree().change_scene_to_file(path)
		assert(_res == OK, "ERROR: %s: Something's wrong when changing to the scene from '%s' to '%s'" % [error_string(_res), old_scene, target_scene.get_path()])
		return
		
	var transition := _create_transition(horizontal, invert, circular)
	var shader := transition.material
	
	is_transitioning = true
	transition.label.modulate.a = 0.0
	
	AutoTween.new(transition.label, "modulate:a", 1.0, 0.5, Tween.TRANS_LINEAR).ignore_pause()
	await AutoTween.Method.new(self,
		(func(val): shader.set_shader_parameter("height", val))
		,0.0, 2.0, 0.7,Tween.TRANS_LINEAR).ignore_pause().finished

	await get_tree().create_timer(delay).timeout # Yeah this is intentional delay
	
	transition.queue_free()
	half_finished.emit()
	
	var res = get_tree().change_scene_to_file(path)
	assert(res == OK, "ERROR: %s: Something's wrong when changing to the scene from '%s' to '%s'" % [error_string(res), old_scene, target_scene.get_path()])
	
	await get_tree().scene_changed
	
	var transition2 := _create_transition(horizontal, invert if circular else !invert, circular)
	var shader2 := transition2.material
	
	AutoTween.new(transition2.label, "modulate:a", 0.0, 0.5, Tween.TRANS_LINEAR).ignore_pause()
	await AutoTween.Method.new(self,
		(func(val): shader2.set_shader_parameter("height", val))
		,2.0, 0.0, 0.7, Tween.TRANS_LINEAR).ignore_pause().finished
		
	transition2.queue_free()
	finished.emit()
	is_transitioning = false
	
func spawn_transition(horizontal := false, invert := false, circular := false) -> void:
	var transition := _create_transition(horizontal, invert, circular)
	var shader := transition.material as ShaderMaterial
	
	transition.label.hide()
	is_transitioning = true
	
	await AutoTween.Method.new(self,
		(func(val): shader.set_shader_parameter("height", val))
		,0.0, 2.0, 0.7, Tween.TRANS_LINEAR).ignore_pause().finished
	
	half_finished.emit()
	if !circular:
		shader.set_shader_parameter("invert", !invert)
	else:
		await get_tree().create_timer(0.1).timeout
		
	await AutoTween.Method.new(self,
		(func(val): shader.set_shader_parameter("height", val))
		,2.0, 0.0, 0.7, Tween.TRANS_LINEAR).ignore_pause().finished
	
	finished.emit()
	transition.queue_free()
	
	is_transitioning = false
	
func _create_transition(horizontal: bool, invert: bool, circular: bool) -> Transition:
	var transition: Transition = transition_path.instantiate()
	get_tree().current_scene.add_child(transition)
	var shader := transition.material
	shader.set_shader_parameter("horizontal", horizontal)
	shader.set_shader_parameter("invert", invert)
	shader.set_shader_parameter("circular", circular)
	return transition
