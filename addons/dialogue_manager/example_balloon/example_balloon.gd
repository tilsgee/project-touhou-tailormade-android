class_name DialogueManagerBalloon extends CanvasLayer

static var instance: DialogueManagerBalloon

signal dialogue_started
signal dialogue_finished
signal responses_popup
signal responses_finished
signal portrait_show(old_texture: Texture2D, new_texture: Texture2D)
signal portrait_hide
signal line_changed

const PORTRAIT_SIZE := Vector2(153.0, 153.0)

@export var next_action: StringName = &"ui_accept"
@export var fast_forward_action: StringName = &"ui_accept"
@export var skip_action: StringName = &"ui_cancel"

var resource: DialogueResource
var temporary_game_states: Array = []
var is_waiting_for_input: bool = false
var will_hide_balloon: bool = false
var locals: Dictionary = {}
var exiting := false

var _locale: String = TranslationServer.get_locale()

var dialogue_line: DialogueLine:
	set(value):
		if value:
			dialogue_line = value
			apply_dialogue_line()
			line_changed.emit()
		else:
			dialogue_finished.emit()
	get:
		return dialogue_line

var mutation_cooldown: Timer = Timer.new()

@onready var balloon: Control = %Balloon
@onready var character_label: RichTextLabel = %CharacterLabel
@onready var dialogue_label: DialogueLabel = %DialogueLabel
@onready var responses_menu: DialogueResponsesMenu = %ResponsesMenu
@onready var progress: Polygon2D = %Progress
@onready var portrait: TextureRect = %Portrait

func _init() -> void:
	instance = self

func _ready() -> void:
	balloon.hide()
	Engine.get_singleton("DialogueManager").mutated.connect(_on_mutated)

	# If the responses menu doesn't have a next action set, use this one
	if responses_menu.next_action.is_empty():
		responses_menu.next_action = next_action

	mutation_cooldown.timeout.connect(_on_mutation_cooldown_timeout)
	add_child(mutation_cooldown)

func _process(delta: float) -> void:
	progress.visible = not dialogue_label.is_typing and dialogue_line.responses.size() == 0


func _notification(what: int) -> void:
	## Detect a change of locale and update the current dialogue line to show the new language
	if what == NOTIFICATION_TRANSLATION_CHANGED and _locale != TranslationServer.get_locale() and is_instance_valid(dialogue_label):
		_locale = TranslationServer.get_locale()
		var visible_ratio = dialogue_label.visible_ratio
		self.dialogue_line = await resource.get_next_dialogue_line(dialogue_line.id)
		if visible_ratio < 1:
			dialogue_label.skip_typing()

## Start some dialogue
func start(dialogue_resource: DialogueResource, title: String, extra_game_states: Array = []) -> void:
	temporary_game_states = [self] + extra_game_states
	is_waiting_for_input = false
	resource = dialogue_resource
	dialogue_started.emit()
	self.dialogue_line = await resource.get_next_dialogue_line(title, temporary_game_states)

## Apply any changes to the balloon given a new [DialogueLine].
func apply_dialogue_line() -> void:
	mutation_cooldown.stop()
	
	progress.hide()
	is_waiting_for_input = false
	balloon.focus_mode = Control.FOCUS_ALL
	balloon.grab_focus()

	character_label.visible = not dialogue_line.character.is_empty()
	character_label.text = tr(dialogue_line.character, "dialogue")

	dialogue_label.hide()
	dialogue_label.dialogue_line = dialogue_line
	
	responses_menu.hide()
	responses_menu.responses = dialogue_line.responses

	will_hide_balloon = false

	dialogue_label.show()
	
	var portrait_res := _process_portrait_tag()
		
	if portrait_res == null:
		portrait_hide.emit()
	else:
		portrait_show.emit(portrait.texture, portrait_res)
		(func():
			portrait.size = PORTRAIT_SIZE
		).call_deferred()
	
	if !dialogue_line.text.is_empty():
		dialogue_label.type_out()
		await dialogue_label.finished_typing

	# Wait for input
	if dialogue_line.responses.size() > 0:
		balloon.focus_mode = Control.FOCUS_NONE
		responses_popup.emit()
	elif dialogue_line.time != "":
		var time = dialogue_line.text.length() * 0.02 if dialogue_line.time == "auto" else dialogue_line.time.to_float()
		await get_tree().create_timer(time).timeout
		next(dialogue_line.next_id)
	else:
		is_waiting_for_input = true
		balloon.focus_mode = Control.FOCUS_ALL
		balloon.grab_focus()

## Go to the next line
func next(next_id: String) -> void:
	dialogue_line = await resource.get_next_dialogue_line(next_id, temporary_game_states)

func _input(event: InputEvent) -> void:
	var m_pressed = event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT
	var m_released = event is InputEventMouseButton and event.is_released() and event.button_index == MOUSE_BUTTON_LEFT
	
	if exiting:
		return
	
	# See if we need to skip typing of the dialogue
	if dialogue_label.is_typing:
		var skip_button_was_pressed: bool = event.is_action_pressed(skip_action)
		var ff_was_pressed: bool = event.is_action_pressed(fast_forward_action) or m_pressed
		var ff_was_released: bool = event.is_action_released(fast_forward_action) or m_released
		if skip_button_was_pressed:
			dialogue_label.skip_typing()
			return
		if ff_was_pressed and !ff_was_released:
			dialogue_label.toggle_fast_forward(true)
		if !ff_was_pressed and ff_was_released:
			dialogue_label.toggle_fast_forward(false)

	if !is_waiting_for_input: return
	if dialogue_line.responses.size() > 0: return


	if m_pressed:
		next(dialogue_line.next_id)
	elif event.is_action_pressed(next_action) and get_viewport().gui_get_focus_owner() == balloon:
		next(dialogue_line.next_id)



func _on_responses_menu_response_selected(response: DialogueResponse) -> void:
	next(response.next_id)
	responses_finished.emit()
	dialogue_label.toggle_fast_forward(Input.is_action_pressed(fast_forward_action))

func _on_mutation_cooldown_timeout() -> void:
	if will_hide_balloon:
		will_hide_balloon = false

func _on_mutated(_mutation: Dictionary) -> void:
	if not _mutation.is_inline:
		is_waiting_for_input = false
		will_hide_balloon = true
		mutation_cooldown.start(0.1)

func _process_portrait_tag() -> ImageTexture:
	var characters = get_node_or_null("/root/Characters")
	
	if characters == null:
		return null
	if dialogue_line.tags.is_empty():
		return null
		
	var expression := dialogue_line.tags[0].capitalize()
	var character := dialogue_line.character.capitalize()
	
	if !characters.portraits.has(character):
		print("Character '%s' is not found." % character)
		return null
	if !characters.portraits[character].has(expression):
		printerr("Expression '%s' for character '%s' is not found." % [expression, character])
		return null
	
	var path: StringName = characters.portraits[character][expression]

	if characters.cached_portraits.has(path):
		if characters.cached_portraits.size() <= 256:
			return characters.cached_portraits[path]
		characters.cached_portraits.clear()
	
	var image := Image.load_from_file(path)
	var texture := ImageTexture.create_from_image(image)

	assert(texture != null, "Invalid path: %s" % path)
	
	characters.cached_portraits.set(path, texture)
	
	return texture
