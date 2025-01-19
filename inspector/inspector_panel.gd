class_name InspectorPanel extends Panel
## Panel for inspecting diagram elements.
##

var canvas: DiagramCanvas
var selection: Selection

func _on_diagram_canvas_selection_changed(new_selection):
	self.selection = new_selection
	
	print("Selection changed: ", selection.count(), " nodes selected")
	var values = selection.get_distinct_values("label")

	if len(values) == 0:
		%NameField.text = ""
	elif len(values) == 1:
		%NameField.text = str(values[0])
	else:
		%NameField.text = "(multiple)"
		
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
	for object in selection.objects:
		object.label = new_text
	# TODO: Call controller
