extends Node

#@onready var _player: Player = owner
@onready var _interactable_detector: Area2D = %InteractableDetector

var _currently_selected_interactable : InteractableSolid #INFO this actoually should be InteractableBody


func _ready() -> void:
	_interactable_detector.body_entered.connect(_on_near_interactable)
	_interactable_detector.body_exited.connect(_on_moving_from_interactable)
	

func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"Interact") and _currently_selected_interactable != null:
		_currently_selected_interactable.interact()
	elif event.is_action_pressed(&"ui_cancel") and ClothAisleUI.instance.visible:
		ClothAisleUI.cancel()

func _on_near_interactable(_body : Node2D):
	if _body is InteractableSolid:
		if _currently_selected_interactable != null:
			_currently_selected_interactable.deselect()
		_body.selected()
		_currently_selected_interactable = _body


func _on_moving_from_interactable(_body : Node2D):
	if _body is InteractableSolid:
		_body.deselect()
		if _currently_selected_interactable == _body:
			_currently_selected_interactable = null
			if _interactable_detector.has_overlapping_bodies():
				var bodies := _interactable_detector.get_overlapping_bodies()
				if _body in bodies:
					bodies.erase(_body)
				if bodies.size() > 0:
					_on_near_interactable(bodies[0])
