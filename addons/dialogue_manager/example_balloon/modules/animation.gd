extends Node

const ANIM_DUR := 0.33
const L_TRANS := Tween.TRANS_LINEAR

@onready var dialogue_cont: PanelContainer = %DialogueContainer
@onready var responses_menu: DialogueResponsesMenu = %ResponsesMenu
@onready var dm_balloon: DialogueManagerBalloon = owner

var _init_dialogue_pos: Vector2
var _init_res_pos: Vector2

func _ready() -> void:
	(func():
		_init_dialogue_pos = dialogue_cont.position
	).call_deferred()
	
	dm_balloon.dialogue_started.connect(func():
		dm_balloon.balloon.show()
		_play_dialogue_anim.call_deferred()
	)
	dm_balloon.dialogue_finished.connect(func():
		dm_balloon.responses_menu.hide()
		dm_balloon.exiting = true
		await _play_exit_dialogue_anim()
		dm_balloon.queue_free()
	)
	dm_balloon.responses_popup.connect(func():
		dm_balloon.responses_menu.show()
		_play_response_anim.call_deferred()
	)
	dm_balloon.portrait_show.connect(func(old_texture: Texture2D, new_texture: Texture2D):
		var portrait := dm_balloon.portrait
		portrait.show()
		if old_texture == new_texture:
			return
		portrait.texture = new_texture
		AutoTween.new(portrait, &"position", Vector2.ZERO, 0.4).from(Vector2(-32.0, 0.0))
		AutoTween.new(portrait, &"modulate:a", 1.0, 0.25, Tween.TRANS_LINEAR).from(0.5)
	)
	dm_balloon.portrait_hide.connect(func():
		dm_balloon.portrait.hide()
	)
	
func _play_dialogue_anim() -> void:
	dialogue_cont.scale = Vector2.ONE
	AutoTween.new(dialogue_cont, &"position", _init_dialogue_pos, ANIM_DUR).from(_init_dialogue_pos + Vector2(0.0, 128.0))
	AutoTween.new(dialogue_cont, &"modulate:a", 1.0, ANIM_DUR, L_TRANS).from(0.0)

func _play_exit_dialogue_anim() -> void:
	var rect_size := dialogue_cont.get_rect().size
	var tgt_scale := Vector2(0.9, 0.9)
	var tgt_pos := _init_dialogue_pos + (rect_size * (Vector2.ONE - tgt_scale) / 2.0)
	AutoTween.new(dialogue_cont, &"scale", tgt_scale, ANIM_DUR).from(Vector2.ONE)
	AutoTween.new(dialogue_cont, &"position", tgt_pos, ANIM_DUR).from(_init_dialogue_pos)
	await AutoTween.new(dialogue_cont, &"modulate:a", 0.0, ANIM_DUR, L_TRANS).from(1.0).finished

func _play_response_anim() -> void:
	_init_res_pos = responses_menu.position
	AutoTween.new(responses_menu, &"position", _init_res_pos, ANIM_DUR).from(_init_res_pos + Vector2(0.0, 32.0))
	AutoTween.new(responses_menu, &"modulate:a", 1.0, ANIM_DUR, L_TRANS).from(0.0)
