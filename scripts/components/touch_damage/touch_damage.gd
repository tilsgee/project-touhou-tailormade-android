extends Area2D

const TICK := 0.1
const DUR := 5.0

@export var damage := 1

var _tick: SceneTreeTimer
var _stop = false

func _ready() -> void:
	area_entered.connect(_send_damage)

func _create_tick() -> void:
	if owner == null or owner.is_queued_for_deletion():
		return
	if get_tree() == null:
		return
	if _stop:
		_stop = false
		_tick = null
		return
	_tick = get_tree().create_timer(TICK)
	_tick.timeout.connect(_create_tick)
	
	if has_overlapping_areas():
		_send_damage(get_overlapping_areas()[0])

func _send_damage(which: Area2D) -> void:
	var parent := which.owner
	var hitbox: HitboxComponent = parent.get_node_or_null("%HitboxComponent")
	var cp := HealthComponent.ChangePackage.new()
	cp.damage = damage
	if hitbox != null and hitbox.active:
		hitbox.hit.emit({&"change_package": cp, &"collision_point": global_position})
	if _tick == null:
		_create_tick()
		get_tree().create_timer(DUR).timeout.connect(func(): _stop = true)
		
