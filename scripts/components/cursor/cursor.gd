class_name Cursor extends Node2D

enum STATE {AIM, CURSOR}

static var instance: Cursor
static var state: STATE

@onready var _hitmarker := %HitMarker
@onready var _hitlabel_cont := %HitLabelContainer
@onready var _hitlabel := %HitLabel

var _accumulated_score: int = 0

func _init() -> void:
	instance = self
	state = STATE.CURSOR
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

func _ready() -> void:
	_hitmarker.modulate.a = 0.0
	_hitlabel_cont.modulate.a = 0.0
	Entity.static_signals.someone_got_hit.connect(func(score: int):
		_hitmarker.show()
		_hitmarker.modulate.a = 1.0
		AutoTween.new(_hitmarker, &"scale", Vector2.ONE, 0.3).from(Vector2(1.2, 1.2))
		AutoTween.new(_hitmarker, &"modulate:a", 0.0, 0.3).set_delay(0.2)
		_hit_label(score)
	)
	Player.instance.died.connect(func():
		_accumulated_score = 0
		_hitlabel_cont.modulate.a = 0.0
		AutoTween.kill_all(_hitlabel.get_parent())
		AutoTween.kill_all(_hitlabel_cont)
	)

func _process(_delta: float) -> void:
	global_position = get_global_mouse_position()

func _hit_label(score: int) -> void:
	_hitlabel_cont.modulate.a = 1.0
	AutoTween.new(_hitlabel.get_parent(), &"position", Vector2.ZERO).from(Vector2(0.0, -8.0))
	AutoTween.new(_hitlabel_cont, &"modulate:a", 0.0, 0.3, Tween.TRANS_LINEAR).set_delay(1.0).finished.connect(func():
		_accumulated_score = 0
	)
	AutoTween.Method.new(self, func(val):
		_hitlabel.text = "+%d" % abs(val),
		_accumulated_score, _accumulated_score + score
	)
	_accumulated_score += score
