extends Control

var text := 'Red Eyes "Lunatic Blast"'

@onready var _label := $Label
@onready var _line := $Line2D

func _ready() -> void:
	_label.text = text
	_line.points[-1].x = 0.0
	(func():
		AutoTween.Method.new(self, func(val):
			_line.points[-1].x = val,
			0.0, _label.get_rect().size.x
		).set_delay(0.5)
	).call_deferred()
	
