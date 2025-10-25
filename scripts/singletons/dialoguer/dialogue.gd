class_name Dialogue extends Control

static var instance: Dialogue
static var persons := {}
static var inputs := {
	"fast_forward" = [&"ui_accept", &"Attack"],
	"next" = [&"ui_accept", &"Attack"]
}

signal finished(normal_exit: bool)
signal changed_id(id: int)
signal changed_col(col: int)
signal col_finished(col: int)

var json_reader:
	get: return %JSONReader
var rich_text: RichTextLabel:
	get: return %Text
var cancel: MarginContainer:
	get: return %Cancel

var variable_substitutes: Array
var speed_multiplier: float
var is_open := false
var is_closing := false
var is_paused := false
var exitable: bool:
	set(val):
		exitable = val
		cancel.visible = val

var _dm: DialogueManager

func json_read(json: JSON):
	json_reader.read(json)

func start(ids: Array[int], dialogue_manager: DialogueManager) -> void:
	if is_open:
		return
	show()
	Animate.fade_in(self, 0.4, false)
	json_reader.start(ids)
	is_open = true
	_dm = dialogue_manager

func exit(_is_normal) -> void:
	if !is_open:
		return
	Animate.fade_out(self, 0.4, false).finished.connect(func():
		hide()
		is_closing = false
	)
	json_reader.exit()
	is_open = false
	is_closing = true

func pause() -> void:
	is_paused = true

func resume() -> void:
	is_paused = false

func get_ids_from_conditions(_conditions: Dictionary) -> Array[int]:
	var id_arr: Array[int] = []
	for id in json_reader.dict_ids:
		if (id.conditions as Dictionary).is_empty():
			var i = json_reader.dict_ids.find(id)
			id_arr.append(i)
			continue
		for key in id.conditions:
			for _key in _conditions:
				if key != _key:
					continue # skip to the next loop
				var value_from_json = id.conditions[key]
				var value_from_cond = _conditions[_key]
				if value_from_json == value_from_cond:
					var i = json_reader.dict_ids.find(id)
					if !id_arr.has(i): # avoid duplicates
						id_arr.append(i)
	return id_arr

func _init() -> void:
	instance = self

func _ready() -> void:
	hide()
	json_reader.dialogue_finished.connect(func():
		finished.emit(true)
		_dm.finished.emit(true)
	)
	json_reader.changed_col.connect(func(col):
		changed_col.emit(col)
		if _dm != null: _dm.changed_col.emit(col)
	)
	col_finished.connect(func(i):
		if _dm != null: _dm.col_finished.emit(i)
	)
	json_reader.changed_id.connect(func(id):
		changed_id.emit(id)
		if _dm != null: _dm.changed_id.emit()
	)
