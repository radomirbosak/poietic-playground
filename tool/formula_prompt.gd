class_name FormulaPrompt extends CanvasPrompt


signal formula_editing_submitted(object_id: int, new_text: String)
signal formula_editing_cancelled(object_id: int)

@onready var formula_field: LineEdit = %FormulaField

@export var grow_duration: float = 0.05

## Currently edited object.
##
@export var edited_object_id: int = -1

var _original_center: Vector2
var _target_width: float = 0.0
var _is_active: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func open(object_id: int, text: String, center: Vector2):
	assert(object_id != null, "Edited object ID not provided")
	self.edited_object_id = object_id
	%FormulaField.text = text
	
	_original_center = center
	_target_width = self.size.x # calculate_editor_width()
	self.size.x = _target_width
	global_position = Vector2(center.x - _target_width / 2, center.y)
	
	_is_active = true
	show()
	%FormulaField.grab_focus()
	%FormulaField.select_all()
	set_process(true)

func _on_reject_formula_button_pressed():
	cancel()

func _on_accept_formula_button_pressed():
	accept_formula(%FormulaField.text)

func accept_formula(new_text: String):
	if !_is_active:
		return
	
	set_process(false)
	hide()
	formula_editing_submitted.emit(edited_object_id, new_text)
	_is_active = false
	edited_object_id = -1

func close():
	if !_is_active:
		return
	set_process(false)
	hide()
	_is_active = false
	edited_object_id = -1

func cancel():
	if !_is_active:
		return
	formula_editing_cancelled.emit(edited_object_id)
	close()

func _on_formula_field_text_submitted(new_text):
	accept_formula(new_text)
