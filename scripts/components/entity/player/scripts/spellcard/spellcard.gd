extends Node2D

signal finished

var active := false
var active_spellcard: Spellcard

@onready var _player: Player = owner
@onready var _shoot_comp: ShootComponent = $ShootCompSC

var _max_bomb: int:
	set(val): Stats.set_stats(&"bomb", &"max_value", val)
	get: return Stats.get_stats(&"bomb", &"max_value")
var _bomb: int:
	set(val): Stats.set_stats(&"bomb", &"value", clampi(val,0, _max_bomb))
	get: return Stats.get_stats(&"bomb", &"value")

func _input(event: InputEvent) -> void:
	if active:
		return
	if !Player.enable_input:
		return
	if event.is_action_pressed(&"Special") and _bomb > 0:
		active = true
		_activate()
		_vfx()
		
func _activate() -> void:
	_bomb -= 1
	_cron_bullet_drop()

	var _lunatic_red_eyes := preload("uid://frshpem0g3jx").new(
		{&"owner": self, &"player": _player, &"shoot_comp": _shoot_comp}
	)
	active_spellcard = Spellcard.create(_lunatic_red_eyes.spellcard_data)
	
	await active_spellcard.finished
	
	_player.hitbox_component.active = true
	active = false
	finished.emit()
	VFX.SpellFX.Pentagon.destroy(self)

func _cron_bullet_drop() -> void:
	while(active):
		Stats.activate_spellcard(&"awoo")
		await get_tree().create_timer(0.2).timeout

func _physics_process(_delta: float) -> void:
	if active:
		_player.hitbox_component.active = false
		_perserve_hover()

func _perserve_hover() -> void:
	Stats.set_stats(&"hover", &"value", Stats.get_stats(&"hover", &"max_value"))

func _vfx() -> void:
	
	VFX.Explosion.EnergyBlast.new(self, load("uid://emu1ol4dffrj"))
	
	await get_tree().physics_frame
	VFX.SpellFX.Pentagon.new(self, Color(1.0, 0.283, 0.426, 1.0), Color(0.992, 0.233, 0.28, 1.0))
	
	await get_tree().physics_frame
	VFX.Particles.BigBlast.new(self)
	
	await get_tree().physics_frame
	VFX.Particles.InwardSpellBlast.new(self, 0.5, Color(1.0, 0.567, 0.697, 1.0))
	
	await get_tree().create_timer(2.0, false).timeout
	VFX.Particles.InwardSpellBlast.new(self, 0.2, Color(1.0, 0.642, 0.907, 1.0))
	
	await get_tree().create_timer(2.0, false).timeout
	VFX.Particles.InwardSpellBlast.new(self, 0.1, Color(0.99, 0.793, 1.0, 1.0))
	
