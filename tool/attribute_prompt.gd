class_name AttributePrompt extends CanvasPrompt

enum ValueType {
	INT,
	FLOAT,
	STRING
}

signal attribute_editing_submitted(object_id: int, attribute: String, new_value: Variant)
signal attribute_editing_cancelled(object_id: int)

@export var edited_object_id: int = -1
@export var edited_attribute: String
@export var edited_value_type: ValueType = ValueType.STRING

func set_icon(texture: Texture):
	if texture:
		%Icon.texture = texture
		%Icon.show()
	else:
		%Icon.hide()
		
func set_label(text: String):
	if text:
		%Label.text = text
		%Label.show()
	else:
		%Label.hide()
	
func open(object_id: int, text: String, center: Vector2, attribute: String):
	assert(object_id != null, "Edited object ID not provided")
	self.edited_object_id = object_id
	self.edited_attribute = attribute
	
	%ValueField.text = text
	
	global_position = Vector2(center.x - self.size.x / 2, center.y)
	
	is_active = true
	show()
	%ValueField.grab_focus()
	%ValueField.select_all()
	set_process(true)

func close():
	if !is_active:
		return
	set_process(false)
	hide()
	is_active = false
	edited_object_id = -1

func _on_value_field_text_submitted(new_text):
	# prints("Value submitted: ", new_text, " for attribute: ", self.edited_attribute)
	if !is_active:
		return
	
	set_process(false)
	hide()
	attribute_editing_submitted.emit(edited_object_id, edited_attribute, new_text)
	is_active = false
