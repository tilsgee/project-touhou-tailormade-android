class_name Enemy extends Entity

const POWER := 300.0

@onready var _shoot_comp := %ShootComponent

var dir_to_player: float:
	get: return signf(Player.instance.global_position.x - global_position.x)

func damage(args: Dictionary) -> void:
	super(args)
	HitFlash.new($Icon)

func _ready() -> void:
	_jump()
	damaged.connect(func(args):
		HealthBar.create(health_component.percent, self)
		HitLabel.create(args.change_package.amount, self)
	)

func _physics_process(delta: float) -> void:
	(func():
		if is_on_floor():
			velocity.x = 0.0
	).call_deferred()
	velocity.y = move_toward(velocity.y, 0.0, delta)
	_shoot_comp.look_at(Player.instance.global_position)
	move_and_slide()

func _jump() -> void:
	velocity.y = -POWER
	velocity.x = dir_to_player * POWER / 2.0
	get_tree().create_timer(randf_range(0.5, 2.0)).timeout.connect(_jump)
	await get_tree().create_timer(randf_range(1.0, 2.5)).timeout
	_shoot_comp.shoot()
