class_name Selection extends Object

signal selection_changed(selection: Selection)

class OrderedSet:
	var items: Array[Variant] = []
	
	func _init(new_items: Array[Variant] = []):
		for item in new_items:
			insert(item)
	
	func insert(item: Variant):
		if not items.has(item):
			items.append(item)

	func intersection(other: OrderedSet) -> OrderedSet:
		var result: OrderedSet = OrderedSet.new()
		for item in items:
			if not other.items.has(item):
				result.insert(item)
		return result

	func form_intersection(other: OrderedSet) -> void:
		var keep: Array[Variant] = []
		for item in items:
			if other.items.has(item):
				keep.append(item)
		self.items = keep

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

	for object in get_design_objects():
		var value = object.attribute(property)
		if value == null:
			continue
		if values.find(value) == -1:
			values.append(value)
	
	return values

func get_type_names() -> Array[String]:
	var result: Array[String] = []
	for item in objects:
		var object = Design.global.get_object(item.object_id)
		if not result.has(object.type_name):
			result.append(object.type_name)

	return result

func get_design_objects() -> Array[DesignObject]:
	var result: Array[DesignObject] = []
	for item in objects:
		if item is DiagramNode:
			var object = Design.global.get_object(item.object_id)
			result.append(object)
		elif item is DiagramConnection:
			var object = Design.global.get_object(item.object_id)
			result.append(object)
	return result

const all_inspector_groups: Array[String] = [
	"Name", "Formula", "Stock", "GraphicalFunction", "Delay", "Smooth"
]

## Get list of inspector group names that are available for this selection.
func distinct_traits() -> Array[String]:
	var groups: OrderedSet = OrderedSet.new(all_inspector_groups)

	var objects = get_design_objects()
	if len(objects) == 0:
		return []

	for object in objects:
		var traits = Global.metamodel.type_get_traits(object.type_name)
		var object_groups: OrderedSet = OrderedSet.new()
		object_groups.insert("Name")
		for trait_name in traits:
			object_groups.insert(trait_name)

		groups.form_intersection(object_groups)
		
	var result: Array[String] = []
	for item in groups.items:
		result.append(item as String)
	print("Distinct traits: ", result)
	return result
