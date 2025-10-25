extends DialogueManager

var d := {"first": true}

func _ready() -> void:
	super._ready()

func start_dialogue() -> void:
	if get_condition().is_empty():
		update_conditions(d)
	super.start_dialogue()
	await finished
	if get_condition() == d:
		update_conditions({"second": true})
