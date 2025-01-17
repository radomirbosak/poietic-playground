class_name InspectorPanel extends Panel
## Panel for inspecting diagram elements.
##

var canvas: DiagramCanvas
var selection: Array[DiagramNode]

func _on_diagram_canvas_selection_changed(new_selection):
	self.selection = new_selection
	
	print("Selection changed: ", len(selection), " nodes selected")
	var values = get_property_values(selection, "name")

	if len(values) == 0:
		$MarginContainer/VBoxContainer/NameField.text = ""
	elif len(values) == 1:
		$MarginContainer/VBoxContainer/NameField.text = str(values[0])
	else:
		$MarginContainer/VBoxContainer/NameField.text = "(multiple)"
		
	pass # Replace with function body.

func get_property_values(selection: Array[DiagramNode], property: String) -> Array[Variant]:
	if property != "name":
		push_error("Only name property can be fetched in this prototype")
		return []
	var values: Array[Variant] = []

	for object in selection:
		if values.find(object.label) == -1:
			values.append(object.label)
	
	return values

func _on_name_field_text_submitted(new_text):
	for object in selection:
		object.label = new_text
	# TODO: Call controller
