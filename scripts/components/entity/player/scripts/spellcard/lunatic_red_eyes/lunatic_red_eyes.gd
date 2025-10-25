extends RefCounted

var spellcard_data := {}

var _data: Dictionary

func _init (data := {&"owner": null, &"player": null, &"shoot_comp": null}) -> void:
	_data = data
	spellcard_data = {
		&"name": 'Lunatic "Red Eyes"',
		&"node": _data.player,
		&"texture": null,
		&"behaviour": _main,
		&"direction": -1
	}

func _main() -> void:
	await _data.owner.get_tree().create_timer(2.0).timeout
	_data.shoot_comp.shoot()
	_data.shoot_comp.bullet_spawned.connect(func():
		SFX.new(_data.owner, SFX.playlist.player.shoot.bullet_small, {&"volume_db": -4.0})
	)
	_data.shoot_comp.individual_bullet_spawned.connect(func(w):
		VFX.Explosion.CircularExplosion.new(w, 15.0, 0.2)
	)
	var cam_shaker := CameraShaker.new(5.0, 0.0, Vector2.ONE, true)
	await AutoTween.new(_data.shoot_comp, &"global_rotation", PI * 2.0, 4.0, Tween.TRANS_LINEAR).finished
	cam_shaker.stop()
	_data.shoot_comp.unshoot()
