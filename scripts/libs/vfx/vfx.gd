class_name VFX extends RefCounted

const scenes := {
	&"explosions": {
		&"explosion1": preload("uid://c4ggga87ktx3r"),
		&"circular": preload("uid://bndtph6e8gcgu"),
		&"shockwave": preload("uid://cvfhh7t0njvth"),
		&"inverted_color": preload("uid://bdq64mvbssqub"),
		&"energy_bast": preload("uid://wbino68hyx6a")
	},
	&"particles": {
		&"bullet_spark1": preload("uid://c1u3fnwh771x3"),
		&"blood_splat1": preload("uid://e4rsgij50m0i"),
		&"inward_spell_blast": preload("uid://b1xuprti224l2"),
		&"outward_spell_blast": preload("uid://cmkikdf7h5kbk"),
		&"big_blast": preload("uid://kmtwa87nkc6i")
	},
	&"etc": {
		&"pentagon": preload("uid://dw4yjhwdihgr1")
	}
}

class Explosion:
	class CircularExplosion:
		func _init(where: Vector2, thiccness := 45.0, duration := 0.5, color := Color.WHITE) -> void:
			var pool: ObjectPool = ObjectPoolService.get_pool(scenes.explosions.circular)
			var instance: Node2D = pool.claim_new()
			instance.thiccness = thiccness
			instance.duration = duration
			instance.color = color
			instance.global_position = where
			
	class RegularExplosion:
		func _init(where: Vector2) -> void:
			var pool: ObjectPool = ObjectPoolService.get_pool(scenes.explosions.explosion1)
			var instance: Node2D = pool.claim_new()
			instance.global_position = where
			CircularExplosion.new(where)
			
	class InvertedColor:
		var instance: BackBufferCopy
		func _init(where: Vector2, thiccness := 0.5, speed := 1.0, initial_size := 0.0, lifetime := 3.0) -> void:
			instance = scenes.explosions.inverted_color.instantiate()
			instance.tracker.global_position = where
			instance.thiccness = thiccness
			instance.speed = speed
			instance.initial_size = initial_size
			instance.lifetime = lifetime
			Game.vfx_node.add_child(instance)
			Arena.other_nodes.add_child(instance.tracker)
			
	class Shockwave:
		func _init(where: Vector2, options := {&"gap": 0.02}) -> void:
			var instance: BackBufferCopy = scenes.explosions.shockwave.instantiate()
			instance.tracker.global_position = where
			for o in options.keys():
				instance.set(o, options[o])
			Game.vfx_node.add_child(instance)
			Arena.other_nodes.add_child(instance.tracker)
			
	class EnergyBlast:
		func _init(where: Variant, gradient: GradientTexture1D = null) -> void:
			var instance: ColorRect = scenes.explosions.energy_bast.instantiate()
			if where is Vector2:
				instance.target_pos = where
			if where is Node:
				instance.follow_node = where
			instance.gradient = gradient
			Arena.other_nodes.add_child(instance)

class Particles:
	class BulletSpark:
		var instance: ParticlesGPU
		func _init(where: Vector2, normal: Vector2, incident_angle: float) -> void:
			var pool: ObjectPool = ObjectPoolService.get_pool(scenes.particles.bullet_spark1)
			instance = pool.claim_new()
			instance.normal = normal
			instance.global_position = where
			instance.incident_angle = incident_angle
			
	class BloodSplat:
		var instance: ParticlesGPU
		func _init(where: Vector2) -> void:
			var pool: ObjectPool = ObjectPoolService.get_pool(scenes.particles.blood_splat1)
			instance = pool.claim_new()
			instance.global_position = where
			
	class InwardSpellBlast:
		func _init(where: Variant, alpha := 1.0, modulate_color := Color.WHITE) -> void:
			var instance: GPUParticles2D = scenes.particles.inward_spell_blast.instantiate()
			instance.where = where
			instance.alpha = alpha
			instance.modulate = modulate_color
			Arena.other_nodes.add_child(instance)
			
	class OutwardSpellBlast:
		func _init(where: Variant, alpha := 1.0, modulate_color := Color.WHITE) -> void:
			var instance: GPUParticles2D = scenes.particles.outward_spell_blast.instantiate()
			instance.where = where
			instance.alpha = alpha
			instance.modulate = modulate_color
			Arena.other_nodes.add_child(instance)

	class BigBlast:
		func _init(where: Variant, alpha := 1.0, modulate_color := Color.WHITE) -> void:
			var instance: GPUParticles2D = scenes.particles.big_blast.instantiate()
			instance.where = where
			instance.alpha = alpha
			instance.modulate = modulate_color
			Arena.other_nodes.add_child(instance)

class SpellFX:
	class Pentagon:
		const META := &"pentagon"
		var instance: Node2D
		func _init(follow_node: Node, inner_color := Color.WHITE, outter_color := Color.WHITE, kanji_rotation_speed := 2.0, pentagon_rotation_speed := 1.0) -> void:
			instance = scenes.etc.pentagon.instantiate()
			instance.follow_node = follow_node
			instance.kanji_rotation_speed = kanji_rotation_speed
			instance.pentagon_rotation_speed = pentagon_rotation_speed
			instance.inner_color = inner_color
			instance.outter_color = outter_color
			Arena.other_nodes.add_child(instance)
			follow_node.set_meta(META, instance)
			
		static func destroy(follow_node: Node) -> void:
			if !follow_node.has_meta(META) or follow_node.get_meta(META) == null:
				return
			follow_node.get_meta(META).destroy()
			
