class_name ShootComponent extends Node2D
# TODO: Support multiple projectiles (?)

enum MECHANISM {SEMI_AUTOMATIC, FULLY_AUTOMATIC}

signal shot
signal unshot
signal bullet_spawned
signal individual_bullet_spawned(where: Vector2)

@export_group("Required Nodes")
@export var projectile_scene: PackedScene

@export_group("Projectile Properties")
@export_subgroup("Properties")
@export var mechanism: MECHANISM = MECHANISM.FULLY_AUTOMATIC
@export_range(1, 100, 1) var projectile_ammount: int = 3
@export_range(10.0, 3000.0, 1.0) var projectile_speed: float = 300.0
@export var damage: int = 1
@export var projectile_lifetime: float = 2
@export_range(1, 3600, 1) var rounds_per_minute: int = 1000
@export_range(0.0, 10.0, 1.0) var angle_randomness: float = 0
@export_range(0.01, 200.0, 5.0) var projectile_spread: float = 30.0
@export_range(0.0, 360.0, 1.0) var projectile_spread_degrees: float = 0.0
@export_range(0.0, 10.0, 0.1) var curve_factor: float = 3.0
@export_range(0.0, 256.0, 0.1) var circular_gap: float = 0.0
@export var gap: bool = false

var _projectile_spawn: Node2D
var _projectile_pool: ObjectPool
var _shoot_timer: Timer
var _held_down: bool = false
		
## Start shooting bullet(s)
func shoot() -> void:
	_held_down = true
	shot.emit()
## Stop shooting bullet(s)
func unshoot() -> void:
	_held_down = false
	unshot.emit()
## Set projectile's parent for determining where is it spawned
func set_projectile_spawn(projectile_spawn: Node2D) -> void:
	_projectile_spawn = projectile_spawn

func _ready():
	_init_pool()
	_init_timer()

func _physics_process(_delta: float) -> void:
	if _shoot_timer.is_stopped() and _held_down:
		_shoot_projectile()
		_shoot_timer.start()
		bullet_spawned.emit()
	match mechanism:
		MECHANISM.FULLY_AUTOMATIC:
			pass
		MECHANISM.SEMI_AUTOMATIC:
			_held_down = false

func _init_timer():
	_shoot_timer = Timer.new()
	_shoot_timer.autostart = false
	_shoot_timer.one_shot = true
	_shoot_timer.wait_time = 1.0 / (rounds_per_minute as float / 60.0)
	add_child(_shoot_timer)
	
func _init_pool():
	_projectile_pool = ObjectPoolService.get_pool(projectile_scene)

func _shoot_projectile():
	var listed_gap:Array[int] = []
	if gap:
		listed_gap.append(round(projectile_ammount/2.0))
		if projectile_ammount %2 == 0:
			listed_gap.append(round(projectile_ammount/2.0) - 1)
			
	if projectile_ammount == 1:
		var projectile := _create_projectile()
		projectile.global_rotation = _projectile_spawn.global_rotation + _rng()
		
		individual_bullet_spawned.emit(projectile.global_position)
		return
		
	for i in projectile_ammount:
		if !listed_gap.has(i):
			var projectile := _create_projectile(i)
			var spawn_line = projectile_spread/2 - ( i * projectile_spread/(projectile_ammount-1) )
			var spawn_line_normalized = spawn_line / (projectile_spread/2)
			var curved_spawn_line: float
			
			curved_spawn_line = curve_factor * cos(spawn_line_normalized*PI/2)
		
			projectile.global_position.y += spawn_line
				
			# Rotates the whole projectiles with matrix transformation, so it doesn't spawn in a straight line,
			# But rotated along the direction its facing
				
			# X = Ax + (Bx - Ax) cos a - (By - Ay) sin a
			# Y = Ay + (Bx - Ax) sin a + (By - Ay) cos a
				
			var Ax = _projectile_spawn.global_position.x
			var Ay = _projectile_spawn.global_position.y
			var Bx = projectile.global_position.x + curved_spawn_line
			var By = projectile.global_position.y
			var alpha = projectile.global_rotation

			var rotated_position := Vector2(
				Ax + (Bx - Ax) * cos(alpha) - (By - Ay) * sin(alpha),
				Ay + (Bx - Ax) * sin(alpha) + (By - Ay) * cos(alpha)
			)
			
			var a: float
			if projectile_spread_degrees != 360:
				a = projectile_spread_degrees / 2 - ((projectile_spread_degrees / (projectile_ammount - 1)) * i)
			else:
				a = projectile_spread_degrees / 2 - ((projectile_spread_degrees / projectile_ammount) * i)
			
			projectile.global_rotation += deg_to_rad(a) + _rng()
			
			var circ_gap := Vector2.from_angle(projectile.global_rotation) * circular_gap
			
			projectile.global_position = rotated_position + circ_gap
			
			individual_bullet_spawned.emit(projectile.global_position)

func _create_projectile(index := 0) -> Projectile:
	var projectile: Projectile = _projectile_pool.claim_new()
	var change_package = HealthComponent.new_package()
	change_package.damage = damage
	projectile.index = index
	projectile.health_change = change_package
	projectile.speed = projectile_speed
	projectile.lifetime = projectile_lifetime
	if _projectile_spawn == null:
		_projectile_spawn = self
	projectile.global_position = _projectile_spawn.global_position
	projectile.global_rotation = _projectile_spawn.global_rotation
	
	return projectile

func _rng() -> float:
	return deg_to_rad(randf_range(angle_randomness, -angle_randomness))
