class_name Selection extends Object

const default_selection_color: Color = Color.YELLOW

signal selection_changed(selection: Selection)

## List of objects in the selection.
var objects: Array[Node2D] = []

## Returns `true` if the selection is empty.
func is_empty() -> bool:
	return objects.is_empty()

func count() -> int:
	return len(objects)

## Remove all objects from the selection and marke them as not selected.
##
func clear():
	if objects.is_empty():
		return
		
	for node in objects:
		if node != null:
			node.set_selected(false)
	objects.clear()
	selection_changed.emit(self)

## Returns `true` if the selection contains given object.
##
func contains(object: Node2D) -> bool:
	return objects.find(object) != -1


## Append object to the selection and mark it as selected.
##
## Appends an object to the selection, if the selection does not already contain
## the object.
##
func append(object: Node2D):
	object.set_selected(true)
	if objects.find(object) != -1:
		return
	objects.append(object)
	selection_changed.emit(self)
	
## Replace the whole selection with given list of objects.
##
## Selection objects before the call of this method will be marked as unselected
## and the new object will be marked as selected.
##
func replace(new_objects: Array[Node2D]):
	for node in objects:
		node.set_selected(false)
	for node in new_objects:
		node.set_selected(true)
	
	objects.clear()
	objects += new_objects
	
	selection_changed.emit(self)

## Remove given object from the selection and mark it as not selected.
func remove(object: Node2D):
	var index = objects.find(object)
	if index != -1:
		object.set_selected(false)
		objects.remove_at(index)
		selection_changed.emit(self)
	
## Toggle object in the selection.
##
## If the selection does not contain the object, it will be added. If the
## selection contains the object, it will be removed. This behaviour is typically
## used when adding/removing objects using the `Shift` key + mouse.
##
func toggle(object: Node2D):
	var index = objects.find(object)
	if index == -1:
		object.set_selected(true)
		objects.append(object)
	else:
		object.set_selected(false)
		objects.remove_at(index)
	selection_changed.emit(self)

## Get distinct values for a given property.
##
## Get all distinc not-null values from the objects in the selection.
## This method is used in the inspector to display and edit a property of
## selected object(s).
##
func get_distinct_values(property: String) -> Array[Variant]:
	var values: Array[Variant] = []

	for object in objects:
		var value = object.get(property)
		if value == null:
			continue
		if values.find(value) == -1:
			values.append(value)
	
	return values
