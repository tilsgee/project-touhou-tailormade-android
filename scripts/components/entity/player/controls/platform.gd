class_name PlayerPlatformControls extends Node2D

@onready var _player: Player = owner
@onready var _platform_check: Area2D = %PlatformCheck

func _input(event: InputEvent) -> void:
	if !Player.enable_input:
		return
	if !_platform_check.has_overlapping_bodies():
		return
	(func():
		if event.is_action_pressed(&"ui_down"):
			_player.global_position.y += 1.0
	).call_deferred()
		
