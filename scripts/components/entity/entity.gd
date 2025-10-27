@abstract class_name Entity extends CharacterBody2D

class StaticSignal:
	@warning_ignore("unused_signal")
	signal someone_got_hit(score: float)

static var static_signals := StaticSignal.new()

@export var score_when_killed := 2048

signal died
signal damaged(args: Dictionary)
signal spawned
signal despawned

var hitbox_component: HitboxComponent:
	get: return %HitboxComponent
var health_component: HealthComponent:
	get: return %HealthComponent
var knockback_factor := 100.0

var _score: int:
	set(val): Stats.set_stats(&"score", &"value", val)
	get: return Stats.get_stats(&"score", &"value")

## Common damage behaviour
func damage(args: Dictionary) -> void:
	damaged.emit(args)
	knockback(args.collision_point)
	
	#AutoTween.new(self, &"modulate", Color.WHITE, 0.25).from(Color.RED)
	#AutoTween.new(self, &"scale", Vector2.ONE, 0.25).from(Vector2(1.05, 1.05))
	VFX.Explosion.CircularExplosion.new(args.collision_point, 12.0, 0.2)
	VFX.Particles.BloodSplat.new(args.collision_point)
	SFX.new(self, SFX.playlist.enemy.hit, {&"volume_db": -12.0})

	_score += abs(args.change_package.amount * 10.0)
	
	static_signals.someone_got_hit.emit(abs(args.change_package.amount * 10.0))

## Common die behaviour
func die() -> void:
	died.emit()
	hitbox_component.active = false
	VFX.Explosion.RegularExplosion.new(global_position)
	SFX.new(self, SFX.playlist.enemy.dead, {&"volume_db": -12.0})
	Payload.create(global_position)
	CameraShaker.new(3.33)
	
	_score += score_when_killed

	static_signals.someone_got_hit.emit(score_when_killed)
	queue_free()

## Common despawn behaviour
func despawn() -> void:
	despawned.emit()
	hide()
	set_physics_process(false)
	propagate_call(&"set_physics_process", [false])

## Common spawn behavious
func spawn() -> void:
	spawned.emit()
	set_physics_process(true)
	propagate_call(&"set_physics_process", [true])

## Common knockback behaviour
func knockback(_collision_point: Vector2) -> void:
	return
	#velocity.x = sign((global_position - collision_point).normalized().x) * knockback_factor
	#if is_on_floor() or self is Player:
	#	velocity.y = - knockback_factor
