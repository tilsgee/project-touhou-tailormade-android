extends Node2D

@export var next_scene := preload("uid://dr3m4h6chre4f")
@onready var _sprites := %SubViewport.get_children()
@onready var _dialogues := [
	preload("uid://dqfolpdlyse8i"),
	preload("uid://dxjdnet0tervv"),
	preload("uid://jqw84qylc4lx"),
	preload("uid://cjs7v7cph512q"),
	preload("uid://cvt5fcjyxtla4")
]
var _active_s = null

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		DialogueManagerBalloon.instance.hide()
		await AutoTween.new(_active_s, &"modulate:a", 0.0, 0.5, Tween.TRANS_LINEAR).from(1.0).finished
		SceneManager.change_scene(next_scene, true)

func _ready() -> void:
	var old_s = null
	for i in _sprites.size():
		var s := _sprites[i]
		_active_s = s
		s.show()
		AutoTween.new(s, &"modulate:a", 1.0, 1.0, Tween.TRANS_LINEAR).from(0.0).finished.connect(func():
			if old_s != null:
				old_s.hide()
		)
		var path: DialogueResource = _dialogues[i]
		DialogueManager.show_dialogue_balloon(path, "")
		await DialogueManager.dialogue_ended
		old_s = s

	await AutoTween.new(_sprites[-1], &"modulate:a", 0.0, 1.0, Tween.TRANS_LINEAR).from(1.0).finished
	SceneManager.change_scene(next_scene, true)
