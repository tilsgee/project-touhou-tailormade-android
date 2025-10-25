extends Node2D

signal power_changed

@onready var _player: Player = owner
@onready var _shoot_comps: Array = [
	[$Stage1a, $Stage1b],
	[$Stage2a, $Stage2b],
	[$Stage3a, $Stage3b]
]

var _alt_index: int = 0:
	set(val):
		_alt_index = wrapi(val, 0, 2)
var _old_power: int
var _power: int:
	get: return int(
		remap(Stats.get_stats(&"power", &"value"), 0,
		Stats.get_stats(&"power", &"max_value"), 1, 4)
	)

var _active_comps: Array:
	get: return _shoot_comps[clampi(_power - 1, 0, 2)]

func _ready() -> void:
	for n in _shoot_comps:
		for m in n:
			m.bullet_spawned.connect(func():
				SFX.new(self, SFX.playlist.player.shoot.bullet_small, {&"volume_db": -8.0})
			)
			m.individual_bullet_spawned.connect(func(where):
				VFX.Explosion.CircularExplosion.new(where, 15.0, 0.2)
			)
	
	_player.died.connect(_unshoot_all)
	power_changed.connect(_update_comp)
	Stats.stats_changed.connect(_check_difference)
	_active_comps = _shoot_comps[0]
	_old_power = _power

func _input(event: InputEvent) -> void:
	if !_player.enable_input:
		_unshoot()
		return
	if event.is_action_pressed(&"Attack"):
		_shoot(_power == 1)
	if event.is_action_released(&"Attack"):
		_unshoot()

func _process(_delta: float) -> void:
	self.look_at(Game.get_cursor_position())

func _update_comp() -> void:
	if Input.is_action_pressed(&"Attack"):
		_unshoot_all()
		_shoot.call_deferred()
	
func _check_difference(which, what, _v) -> void:
	if which == &"power" and what == &"value":
		if _old_power == _power:
			return
		if _power > _old_power:
			_play_upgrade_sfx()
		power_changed.emit()
		_old_power = _power

func _unshoot() -> void:
	for n in _active_comps:
		n.unshoot()

func _unshoot_all() -> void:
	for n in _shoot_comps:
		for m in n:
			m.unshoot()
		
func _shoot(alternate := false) -> void:
	if alternate:
		_alt_index += 1
		_active_comps[_alt_index].shoot()
		return
		
	for n in _active_comps:
		n.shoot()

func _play_upgrade_sfx() -> void:
	pass
