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
	SceneManager.change_scene.call_deferred(next_scene, true)
