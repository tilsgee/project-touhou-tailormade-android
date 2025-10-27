extends Node

const RESPAWN_TIME := 1.25

@onready var _player: Player = owner
@onready var _pos_ticker := %PositionTicker

var player_max_sub_health: int:
	set(val): Stats.set_stats(&"player_health", &"max_sub_value", val)
	get: return Stats.get_stats(&"player_health", &"max_sub_value")
	
var player_sub_health: int:
	set(val): Stats.set_stats(&"player_health", &"sub_value", mini(val, player_max_sub_health))
	get: return Stats.get_stats(&"player_health", &"sub_value")
	
var player_max_health: int:
	set(val): Stats.set_stats(&"player_health", &"max_value", val)
	get: return Stats.get_stats(&"player_health", &"max_value")
	
var player_health: int:
	set(val): Stats.set_stats(&"player_health", &"value", mini(val, player_max_health))
	get: return Stats.get_stats(&"player_health", &"value")

var power: int:
	set(val): Stats.set_stats(&"power", &"value", maxi(val, 0))
	get: return Stats.get_stats(&"power", &"value")

func _ready() -> void:
	_player.health_component.health = player_sub_health
	_player.hitbox_component.active = false
	await get_tree().create_timer(1.0).timeout
	_player.hitbox_component.active = true
	
	Stats.stats_changed.connect(func(which: StringName, what: StringName, value: Variant):
		if which == &"player_health" and what == &"sub_value":
			_player.health_component.health = value
	)
	
func die() -> void:
	Player.enable_input = false
	power -= 15
	
	_player.hide()
	_player.velocity = Vector2.ZERO

	CameraShaker.new(20.0, 1.0)
	SFX.new(_player, SFX.playlist.player.dead, {&"volume_db": -6.0}).no_pitch_change().process_always()
	
	VFX.Explosion.CircularExplosion.new(_player.global_position, 50.0, 0.33)
	VFX.Explosion.CircularExplosion.new(_player.global_position, 100.0)
	VFX.Explosion.Shockwave.new(_player.global_position, {&"gap": 0.01, &"feather": 0.3, &"speed": 8.0})
	
	_lolk_death_vfx()
	
	get_tree().create_timer(RESPAWN_TIME).timeout.connect(_respawn)

func damage(args: Dictionary) -> void:
	_player.hitbox_component.active = false
	player_sub_health -= 1
	
	SFX.new(_player, SFX.playlist.player.hit, {&"volume_db": -6.0})
	VFX.Particles.BloodSplat.new(_player.global_position)
	
	if !_player.health_component.is_dead:
		CameraShaker.new()
		_player.knockback(args.collision_point)
		await _blink()
		_player.hitbox_component.active = true

func _respawn() -> void:
	if player_health == 0:
		Game.game_over()
		return
	Payload.create(_player.global_position, Payload.TYPE.POWER, false, 10)
	Player.enable_input = true
	_player.health_component.is_dead = false
	_player.global_position = _pos_ticker.last_valid_position + Vector2(0.0, -64.0)
	_player.health_component.health = player_max_sub_health
	player_sub_health = player_max_sub_health
	player_health -= 1
	_player.show()
	await _blink()
	_player.hitbox_component.active = true

func _blink() -> void:
	for _i in range(10):
		_player.modulate.a = 0.15
		await get_tree().create_timer(0.1, false).timeout
		_player.modulate.a = 0.85
		if get_tree().paused: await get_tree().physics_frame
		await get_tree().create_timer(0.1, false).timeout
	_player.modulate.a = 1.0

func _lolk_death_vfx() -> void:
	const GAP := 64.0
	const DUR := 1.2
	const THICC := 5.0
	
	var vfxs := []
	
	vfxs.append(VFX.Explosion.InvertedColor.new(_player.global_position, THICC, DUR) )
	
	await get_tree().create_timer(0.1).timeout
	
	vfxs.append(VFX.Explosion.InvertedColor.new(_player.global_position + Vector2(GAP, 0.0), THICC, DUR) )
	vfxs.append(VFX.Explosion.InvertedColor.new(_player.global_position + Vector2(-GAP, 0.0), THICC, DUR) )
	vfxs.append(VFX.Explosion.InvertedColor.new(_player.global_position + Vector2(0.0, GAP), THICC, DUR) )
	vfxs.append(VFX.Explosion.InvertedColor.new(_player.global_position + Vector2(0.0, -GAP), THICC, DUR) )
	
	await get_tree().create_timer(0.75).timeout
	
	vfxs.append(VFX.Explosion.InvertedColor.new(_player.global_position, THICC, 1.5) )
	
	Stats.send_notification(&"drop_projectiles")
	
	await get_tree().create_timer(1.5, false).timeout
		
	for v in vfxs:
		v.instance.queue_free()
