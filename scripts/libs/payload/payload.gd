class_name Payload extends CharacterBody2D

enum TYPE {AUTO = 0, SMALL_POINT = 16, POINT = 32, POWER = 64, BOMB = 128, HEALTH = 256}

const BASE_SCORE := 4
const SPEED := 1500.0
const LIFETIME := 3.0
const Y_DROP := 16.0

static var _payload_scene: PackedScene = preload("uid://dicasa7xix1bv")

@onready var _gravity: Gravity = %Gravity

var type: TYPE
var force_pick := false
var ready_pick := false

var _score: int:
	set(val): Stats.set_stats(&"score", &"value", val)
	get: return Stats.get_stats(&"score", &"value")
var _player_max_sub_health: int:
	set(val): Stats.set_stats(&"player_health", &"max_sub_value", val)
	get: return Stats.get_stats(&"player_health", &"max_sub_value")
var _player_sub_health: int:
	set(val):
		if val > _player_max_sub_health:
			Stats.set_stats(&"player_health", &"sub_value", 1)
			_player_health += 1
		else:
			Stats.set_stats(&"player_health", &"sub_value", val)
	get: return Stats.get_stats(&"player_health", &"sub_value")
var _player_max_health: int:
	set(val): Stats.set_stats(&"player_health", &"max_value", val)
	get: return Stats.get_stats(&"player_health", &"max_value")
var _player_health: int:
	set(val): Stats.set_stats(&"player_health", &"value", mini(val, _player_max_health))
	get: return Stats.get_stats(&"player_health", &"value")
var _max_bomb: int:
	set(val): Stats.set_stats(&"bomb", &"max_value", val)
	get: return Stats.get_stats(&"bomb", &"max_value")
var _bomb: int:
	set(val): Stats.set_stats(&"bomb", &"value", mini(val, _max_bomb))
	get: return Stats.get_stats(&"bomb", &"value")
var _max_power: int:
	set(val): Stats.set_stats(&"power", &"max_value", val)
	get: return Stats.get_stats(&"power", &"max_value")
var _power: int:
	set(val): Stats.set_stats(&"power", &"value", mini(val, _max_power))
	get: return Stats.get_stats(&"power", &"value")
var _coin: int:
	set(val): Stats.set_stats(&"coin", &"value", val)
	get: return Stats.get_stats(&"coin", &"value")

var _timer: SceneTreeTimer
var _init_y: float

static func create(where: Vector2, which := TYPE.AUTO, force_pickup := false, ammount := 0) -> void:
	var actual_ammount: int
	var actual_type = _determine_type(which)
	
	if actual_type != Payload.TYPE.BOMB and actual_type != Payload.TYPE.HEALTH:
		actual_ammount = randi_range(2, 4)
	if ammount != 0:
		actual_ammount = abs(ammount)
		
	for i in range(actual_ammount):
		var pool: ObjectPool = ObjectPoolService.get_pool(_payload_scene)
		var instance: Payload = pool.claim_new()
		instance.type = actual_type
		instance.global_position = where
		if force_pickup:
			instance.force_pick = force_pickup

static func _determine_type(which: TYPE) -> TYPE:
	if which == Payload.TYPE.AUTO:
		var rng := randi_range(0, 50)
		#if rng >= 45: return Payload.TYPE.BOMB
		if rng >= 30: return Payload.TYPE.POWER
		elif rng == 1: return Payload.TYPE.HEALTH
		else: return Payload.TYPE.POINT
	return which

func _ready() -> void:
	_pool_unclaim()
	_hide_all()
	_gravity.speed_modifier = 0.5
	Stats.spell_card.connect(func(_w, _v): force_pick = true)

func _pool_claim() -> void:
	_claim.call_deferred()
	_timer = get_tree().create_timer(LIFETIME + randf_range(-0.5, 0.5))
	_timer.timeout.connect(_deactivate)

func _pool_unclaim() -> void:
	hide()
	_hide_all()
	force_pick = false
	ready_pick = false
	velocity = Vector2.ZERO
	_gravity.toggle(false)
	set_physics_process(false)
	Trail.remove(self)
	if _timer != null and _timer.timeout.is_connected(_deactivate):
		_timer.timeout.disconnect(_deactivate)

func _claim() -> void:
	_activate.call_deferred()
	_gravity.toggle(true)
	if !force_pick:
		var col: Color
		match type:
			TYPE.SMALL_POINT: col = Color.SKY_BLUE
			TYPE.HEALTH: col = Color.ORANGE_RED
			TYPE.POINT: col = Color.YELLOW
			TYPE.POWER: col = Color.RED
			TYPE.BOMB: col = Color.PURPLE
		col.a = 0.3 if type == TYPE.SMALL_POINT else 0.7
		Trail.new(Arena.other_nodes, self, col, 2.0 if type == TYPE.SMALL_POINT else 4.0)
	get_tree().create_timer(0.33, false).timeout.connect(func(): ready_pick = true)
	_init_y = global_position.y
	
func _physics_process(delta: float) -> void:
	var dist := global_position.distance_to(Player.instance.global_position)
	if force_pick or (dist <= 124.0 and ready_pick):
		_pick(dist, delta)
		if _gravity.active:
			_gravity.toggle(false)
	elif global_position.y >= _init_y + Y_DROP:
		velocity = Vector2.ZERO
	move_and_slide()

func _activate() -> void:
	show()
	match type:
		TYPE.SMALL_POINT: _show_sprite(%SmallPoint)
		TYPE.HEALTH: _show_sprite(%Health)
		TYPE.BOMB: _show_sprite(%Bomb)
		TYPE.POWER: _show_sprite(%Power)
		_: _show_sprite(%Point)
		
	if type != TYPE.SMALL_POINT:
		velocity = Vector2(randf_range(-300.0, 300.0), randf_range(-100.0, -300.0))

	set_physics_process(true)
		
func _deactivate() -> void:
	if ObjectPoolService.get_pool_from_object(self).is_claimed(self):
		ObjectPoolService.unclaim(self)
	VFX.Explosion.CircularExplosion.new(global_position, 20.0, 0.5)
		
func _pick(dist: float, delta: float) -> void:
	var dir := (Player.instance.global_position - global_position).normalized()
	var speed := SPEED
	if type == TYPE.SMALL_POINT:
		speed = SPEED * 0.75
	global_position += dir * speed * delta * (1.0 if force_pick else 0.4)
	
	if dist <= 12.0:
		_score += BASE_SCORE * type
		match type:
			TYPE.BOMB: _bomb += 1
			TYPE.POWER: _power += 1
			TYPE.HEALTH: _player_sub_health += 1
			TYPE.POINT:
				_coin += 1
				HitLabel.create(1, Player.instance, Vector2(0.0, -92.0)).scale = Vector2(0.7, 0.7)
		_deactivate()

func _show_sprite(which: Sprite2D) -> void:
	which.show()

func _hide_all() -> void:
	for n in get_children():
		n.hide()
