class_name ArenaTailormade extends Arena

const ENEMY_YOUKAI = preload("uid://c673lbbcna1t7")

#@onready var clothes: Node2D = %Clothes

static var clothes_node: Node2D:
	get: return instance.get_node("%Clothes")

@onready var _enemies_node: Node2D = %Enemies
@onready var _youkai_spawn_pos: Marker2D = %YoukaiSpawnPos

func _ready() -> void:
	super._ready()
	for n in clothes_node.get_children():
		if n is not ClothAisle:
			continue
		
		n = n as ClothAisle
		n.open_cloth_aisle.connect(ClothAisleUI.show_ui)
	Camera.set_cam_limit(Vector4(
		240.0, 120.0,
		720.0, 420.0
	))
	
	_spawn_youkai()


func _spawn_youkai():
	var _new_youkai : EnemyYoukai = ENEMY_YOUKAI.instantiate()
	_enemies_node.add_child(_new_youkai)
	_new_youkai.position = _youkai_spawn_pos.position
	get_tree().create_timer(randf_range(3.0, 7.0)).timeout.connect(_spawn_youkai)
