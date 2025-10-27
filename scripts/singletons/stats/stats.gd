extends Node

signal stats_changed(which: StringName, what: StringName, value: Variant)
signal stats_notification(what: StringName, value: Variant)
signal spell_card(what: StringName, value: Variant)

var _stats := {
	&"player_health": {
		&"sub_value": 3,
		&"max_sub_value": 3,
		&"value": 2,
		&"max_value": 9
	},
	&"hover": {
		&"value": 100.0,
		&"max_value": 100.0
	},
	&"power": {
		&"value": 1,
		&"max_value": 60
	},
	&"bomb": {
		&"value": 3,
		&"max_value": 32
	},
	&"dash": {
		&"value": 100,
		&"max_value": 100
	},
	&"score": {
		&"value": 0,
		&"point_item": 0
	},
}

func send_notification(what: StringName, value: Variant = null) -> void:
	stats_notification.emit(what, value)

func activate_spellcard(what: StringName, value: Variant = null) -> void:
	spell_card.emit(what, value)

func set_stats(which: StringName, what: StringName, value: Variant) -> void:
	_stats[which][what] = value
	stats_changed.emit(which, what, value)

func get_stats(which: StringName, what: StringName) -> Variant:
	return _stats[which][what]
