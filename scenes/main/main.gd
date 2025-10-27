class_name App extends Node

static var data := {
	"name": ProjectSettings.get_setting("application/config/name"),
	"name_localized": ProjectSettings.get_setting("application/config/name_localized"),
	"description": ProjectSettings.get_setting("application/config/description"),
	"version": ProjectSettings.get_setting("application/config/version"),
	"platform": OS.get_name(),
	"debug_build": OS.is_debug_build(),
	"web_build": OS.get_name().contains("Web")
}

@export var next_scene: PackedScene = load("res://scenes/game/game.tscn")

func _ready() -> void:
	var platform = OS.get_name()
	var scene_instance = next_scene.instantiate()

	if platform == "Android":
		var android_script_path = "res://scenes/game/scripts/game_android.gd"
		if ResourceLoader.exists(android_script_path):
			var android_script = load(android_script_path)
			scene_instance.set_script(android_script)
			print("✅ Using GameAndroid script")
		else:
			print("⚠️ Android script not found, using default script")
	else:
		print("🖥️ Desktop mode active")

	# Change scene to the prepared instance
	SceneManager.change_scene.call_deferred(scene_instance, true)
