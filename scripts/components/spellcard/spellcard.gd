class_name Spellcard extends Control

signal finished

const MODULATE := 0.5
const Y_OFFSET := Vector2(0.0, 82.0)
const X_OFFSET := Vector2(-256.0, 0.0)
const ANIM_DURATION := 2.5
const FADE_DURATION := 0.5

static var _spellcard_scene: PackedScene = preload("uid://dyarrute61j8t")
static var _label_scene: PackedScene = preload("uid://ch2mjqla7ehqk")

var data: Dictionary

@onready var _container := %Container
@onready var _left_texture := %LeftTexture
@onready var _right_texture := %RightTexture
@onready var _margins := {
	&"top_left": %MTL,
	&"top_right": %MTR,
	&"bottom_left": %MBL,
	&"bottom_right": %MBR
}
#@onready var _init_bloom := Game.post_processing.environment.glow_bloom
#var _spell_bloom: float:
	#get: return _init_bloom * 2.0

static func create(spellcard_data: Dictionary = {&"name": "", &"node": null, &"texture": null, &"behaviour": null, &"direction": 1}) -> Spellcard:
	var instance: Spellcard = _spellcard_scene.instantiate()
	var label: Control = _label_scene.instantiate()
	instance.data = spellcard_data
	instance.data.merge({&"label": label})
	label.text = spellcard_data.name
	Game.ui_node.add_child(instance)
	Game.ui_node.add_child(label)
	return instance

func end() -> void:
	finished.emit()
	if !is_queued_for_deletion():
		queue_free.call_deferred()

func _ready() -> void:
	_make_opaque()
	_hide_textures()
	_assign_texture(_right_texture if data.direction > 0 else _left_texture)
	[_animation_one, _animation_two].pick_random().call()
	_play_sfx()
	_animate_label.call_deferred(data.label)
	_shake()
	
	await data.behaviour.call()

	end()

func _make_opaque() -> void:
	modulate.a = MODULATE

func _hide_textures() -> void:
	_left_texture.hide()
	_right_texture.hide()

func _assign_texture(which: TextureRect) -> void:
	if data.texture != null:
		which.texture = data.texture
	which.show()

func _play_sfx() -> void:
	SFX.new(self, SFX.playlist.ui.spellcard, {&"volume_db": 8.0})

func _animate_label(label: Control) -> void:
	var label_size = Vector2(label.get_child(0).size.x, 0.0) * data.direction
	var offset = Vector2(64.0, 0.0) * data.direction
	var tgt_in = _margins.bottom_left.global_position if data.direction < 0 else _margins.bottom_right.global_position - label_size + (offset  / 2.0)
	var tgt_out = _margins.top_left.global_position if data.direction < 0 else _margins.top_right.global_position - label_size + (offset  / 2.0)

	
	label.global_position = tgt_in
	AutoTween.new(label, &"scale", Vector2.ONE, 1.0).from(Vector2(5.0, 5.0))
	AutoTween.new(label, &"global_position", tgt_out, 1.0).set_delay(ANIM_DURATION)
	
	finished.connect(func():
		await AutoTween.new(label, &"global_position", tgt_out + label_size + offset).finished
		label.queue_free()
	)

func _shake() -> void:
	CameraShaker.new(15.0, 1.0)

func _animation_one() -> void:
	AutoTween.new(_container, &"position", -Y_OFFSET, ANIM_DURATION, Tween.TRANS_LINEAR).from(Y_OFFSET)
	await AutoTween.new(_container, &"modulate:a", 1.0, FADE_DURATION, Tween.TRANS_LINEAR).from(0.0).finished
	AutoTween.new(_container, &"modulate:a", 0.0, FADE_DURATION, Tween.TRANS_LINEAR).set_delay(ANIM_DURATION - (FADE_DURATION * 2))

func _animation_two() -> void:
	AutoTween.new(_container, &"modulate:a", 1.0, FADE_DURATION, Tween.TRANS_LINEAR).from(0.0)
	AutoTween.new(_container, &"position", Vector2.ZERO).from(X_OFFSET * (-data.direction))
	
	await get_tree().create_timer(ANIM_DURATION, false).timeout
	
	_animate_scale_out(_right_texture if data.direction > 0 else _left_texture)
	AutoTween.new(_container, &"modulate:a", 0.0, FADE_DURATION * 2, Tween.TRANS_LINEAR).from(1.0)

func _animate_scale_out(which: TextureRect) -> void:
	var scaled := Vector2(1.5, 1.5)
	var rect_size := which.get_rect().size
	var rect_size_scaled := rect_size * scaled
	var delta_size = rect_size_scaled - rect_size
	var target_pos = - delta_size / 2.0
	
	AutoTween.new(which, &"scale", scaled, FADE_DURATION * 2)
	AutoTween.new(which, &"position", target_pos, FADE_DURATION * 2).as_relative()
