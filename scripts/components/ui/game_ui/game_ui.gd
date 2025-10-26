class_name GameUI extends MarginContainer

const ONE_CLOTHING_TEX_RECT = preload("uid://bkb23u5dnn365")

static var instance: GameUI

@onready var _hover_stats := %HoverStats
@onready var _dash_stats := %DashStats
@onready var _score_label := %Score
@onready var _power_stats := %PowerStats
@onready var _power_label := %PowerLabel
@onready var _fps := %FPS

@onready var _health_cont := %HealthContainer
@onready var _health_point: TextureProgressBar = _health_cont.get_child(0)

@onready var _spell_cont := %SpellContainer
@onready var _spell_point: TextureProgressBar = _spell_cont.get_child(0)

@onready var _held_clothes_cont: HBoxContainer = %HeldClothesContainer


var _player_max_sub_health: int:
	get: return Stats.get_stats(&"player_health", &"max_sub_value")

var _player_sub_health: int:
	get: return Stats.get_stats(&"player_health", &"sub_value")

var _max_bomb: int:
	set(val): Stats.set_stats(&"bomb", &"max_value", val)
	get: return Stats.get_stats(&"bomb", &"max_value")

var _bomb: int:
	set(val): Stats.set_stats(&"bomb", &"value", mini(val, _max_bomb))
	get: return Stats.get_stats(&"bomb", &"value")

var _max_power: int:
	set(val): Stats.set_stats(&"power", &"max_value", val)
	get: return Stats.get_stats(&"power", &"max_value")


var _last_health_point: TextureProgressBar:
	get: return _health_cont.get_children()[-1]

func _init() -> void:
	instance = self

func _ready() -> void:
	_connect_signals()
	_update_fps()
	_initialize()

func _connect_signals() -> void:
	Stats.stats_changed.connect(func(which: StringName, what: StringName, value: Variant):
		match which:
			&"hover":
				var max_val: float = Stats.get_stats(&"hover", &"max_value")
				_hover_stats.value = remap(value, 0.0, max_val, 0.0, 100.0)
			&"dash":
				_dash_stats.value = Stats.get_stats(&"dash", what)
			&"score":
				if what != &"value":
					return
				const DURATION := 0.5
				var old_val := (_score_label.text as String).to_int()
				AutoTween.new(_score_label, &"position:y", 0.0, DURATION).from(-8.0)
				AutoTween.Method.new(self, func(val):
					_score_label.text = str(val),
					old_val, Stats.get_stats(&"score", &"value"), DURATION
				)
			&"player_health":
				_update_health(what, value)
			&"bomb":
				_update_spell(what, value)
			&"power":
				_update_power(what, value)
	)
	Stats.stats_notification.connect(func(what: StringName, _value: Variant):
		match what:
			&"hover_full":
				AutoTween.new(_hover_stats, &"modulate", Color.WHITE, 1.5).from(Color(10.0,10.0,10.0))
			&"hover_depleted":
				AutoTween.new(_hover_stats, &"modulate:r", 1.0, 1.5).from(10.0)
			&"dash_full":
				AutoTween.new(_dash_stats, &"scale", Vector2.ONE).from(Vector2(1.1, 1.1))
	)
	Player.instance.damaged.connect(func():
		var new_rect := ColorRect.new()
		new_rect.size = Game.SCREEN_RES
		new_rect.color = Color.RED
		Game.ui_node.add_child(new_rect)
		AutoTween.new(new_rect, &"modulate:a", 0.0, 0.5, Tween.TRANS_LINEAR).from(0.5).finished.connect(new_rect.queue_free)
	)

func _update_fps() -> void:
	get_tree().create_timer(1.0).timeout.connect(_update_fps)
	_fps.text = "FPS: %1d" % Engine.get_frames_per_second()

func _initialize() -> void:
	var ph = Stats.get_stats(&"player_health", &"value")
	var sp = Stats.get_stats(&"bomb", &"value")
	var ph_sub = Stats.get_stats(&"player_health", &"sub_value")
	var powr = Stats.get_stats(&"power", &"value")
	Stats.set_stats(&"player_health", &"value", ph)
	Stats.set_stats(&"player_health", &"sub_value", ph_sub)
	Stats.set_stats(&"bomb", &"value", sp)
	Stats.set_stats(&"power", &"value", powr)
	
func _update_health(what: StringName, value: int) -> void:
	var remap_health := func(val):
		return remap(val, 0, _player_max_sub_health, 0.0, 100.0)

	if what == &"sub_value":
		_last_health_point.value = remap_health.call(value)
		if value == 0 and _bomb <= 2:
			_bomb = 2
		
	if what == &"value":
		for c in _health_cont.get_children():
			if c != _health_point:
				c.queue_free()
			else:
				c.value = 100.0
		
		for i in range(value):
			var hp := _health_point.duplicate()
			_health_cont.add_child(hp)
			hp.value = 100.0

		_last_health_point.value = remap_health.call(_player_sub_health)

func _update_spell(what: StringName, value: int) -> void:
	if what != &"value":
		return
	for c in _spell_cont.get_children():
		if c != _spell_point:
			c.queue_free()
		if value == 0:
			c.hide()
		else:
			c.show()
	for i in range(value - 1):
		var hp := _spell_point.duplicate()
		_spell_cont.add_child(hp)
		hp.show()

func _update_power(what: StringName, value: int) -> void:
	if what != &"value":
		return
	
	var increment := _max_power / 3.0
	var partial_progress := value % roundi(increment)
	var whole_progress := int(remap(value, 0, _max_power, 1, 4))
	
	if value != _max_power:
		_power_stats.value = remap(partial_progress, 0, increment, 0.0, 100.0)
		_power_label.text = str(whole_progress) if whole_progress != 3 else "MAX"
	else:
		_power_stats.value = 100.0


func update_clothes(_clothes_array : Array[ClothingData]):
	for n in _held_clothes_cont.get_children():
		n.queue_free()
		
	for _c_data in _clothes_array:
		var new_clothing_icon : TextureRect = ONE_CLOTHING_TEX_RECT.instantiate()
		new_clothing_icon.texture = _c_data.cloth_texture
		_held_clothes_cont.add_child(new_clothing_icon)
