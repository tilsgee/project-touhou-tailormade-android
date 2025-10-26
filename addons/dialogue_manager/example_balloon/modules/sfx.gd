extends Node

@onready var dm_balloon: DialogueManagerBalloon = owner
@onready var sfx_player: AudioStreamPlayer = %SFXPlayer

var _every := 3
var _index := 0:
	set(val): _index = wrapi(val, 0, 11)

func _ready() -> void:
	(func():
		dm_balloon.dialogue_label.spoke.connect(func(_l, _i, _s):
			if _index % _every == 0:
				sfx_player.play()
			_index += 1
		)
		
	).call_deferred()
	
	dm_balloon.line_changed.connect(_process_sfx)

func _process_sfx() -> void:
	const PATH := &"sfx_path"
	const CACHE := &"sfx_cache"
	
	if !sfx_player.has_meta(CACHE):
		sfx_player.set_meta(CACHE, {})
		
	var sfx_path := _process_sfx_path()
	var curr_sfx = sfx_player.get_meta(PATH) if sfx_player.has_meta(PATH) else null
	var sfx_cache: Dictionary = sfx_player.get_meta(CACHE)
	
	if curr_sfx == sfx_path:
		return
	
	if sfx_cache.has(sfx_path):
		sfx_player.stream = sfx_cache[sfx_path]
		return
	
	var new_stream: AudioStream = load(sfx_path)
	
	sfx_cache.set(sfx_path, new_stream)
	
	sfx_player.stream = new_stream
	

func  _process_sfx_path() -> StringName:
	var characters = get_node_or_null("/root/Characters")
	var character := dm_balloon.dialogue_line.character.capitalize()
	var default_sfx = characters.get(&"default_sfx") if characters.get(&"default_sfx") != null else &"res://addons/dialogue_manager/assets/default_sfx.wav"
	
	if characters == null:
		return default_sfx
		
	if characters.portraits.has(character) and characters.portraits[character].has(&"SFX"):
		return characters.portraits[character][&"SFX"]
		
	return default_sfx
