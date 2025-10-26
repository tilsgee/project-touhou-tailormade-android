class_name EnemyYoukai extends Entity

const POWER := 300.0

@onready var _shoot_comp := %ShootComponent
#@onready var _health_comp: HealthComponent = %HealthComponent

var dir_to_player: float:
	get: return signf(Player.instance.global_position.x - global_position.x)

var _next_target: Vector2
var _speed := 50.0
var _is_aggro := false

func damage(args: Dictionary) -> void:
	super(args)
	HitFlash.new($Icon)

func _ready() -> void:
	#_jump()
	damaged.connect(func(args):
		HealthBar.create(health_component.percent, self)
		HitLabel.create(args.change_package.amount, self)
		if not _is_aggro:
			_is_aggro = true
			get_tree().create_timer(randf_range(1.0, 2.5)).timeout.connect(_shoot)
	)
	_find_random_aisle()
	


func _physics_process(_delta: float) -> void:
	#(func():
		#if is_on_floor():
			#velocity.x = 0.0
	#).call_deferred()
	#velocity.y = move_toward(velocity.y, 0.0, delta)
	if _is_aggro:
		_next_target = Player.instance.global_position
	
	if _next_target != null:
		var _distance_vec = _next_target - self.global_position
		velocity = _distance_vec.normalized() * _speed

	_shoot_comp.look_at(Player.instance.global_position)
	move_and_slide()


func _find_random_aisle():
	if ArenaTailormade.instance.clothes_node:
		var aisles : Array = ArenaTailormade.instance.clothes_node.get_children()
		var _random_aisle : ClothAisle = aisles.pick_random()
		_next_target = _random_aisle.middle_pos


func _shoot():
	_shoot_comp.shoot()
	get_tree().create_timer(randf_range(1.0, 2.5)).timeout.connect(_shoot)
	
#func _jump() -> void:
	#velocity.y = -POWER
	#velocity.x = dir_to_player * POWER / 2.0
	#get_tree().create_timer(randf_range(0.5, 2.0)).timeout.connect(_jump)
	#await get_tree().create_timer(randf_range(1.0, 2.5)).timeout
	#_shoot_comp.shoot()
