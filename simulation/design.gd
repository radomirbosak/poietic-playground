class_name Design extends Object

signal design_changed()

static var global: Design = Design.new()

var design_objects: Dictionary = {}

func all_nodes() -> Array[DesignObject]:
	var result: Array[DesignObject] = []
	for object in design_objects.values():
		if object.structure == DesignObject.StructureType.NODE:
			result.append(object)
	return result

func all_edges() -> Array[DesignObject]:
	var result: Array[DesignObject] = []
	for object in design_objects.values():
		if object.structure == DesignObject.StructureType.EDGE:
			result.append(object)
	return result

func add_object(object: DesignObject):
	design_objects[object.object_id] = object
	design_changed.emit()
		
func get_object(id: int) -> DesignObject:
	return design_objects[id]

func all_objects() -> Array[DesignObject]:
	# FIXME: Remove this in Godot 4.4 when we get typed dictionaries
	var result: Array[DesignObject] = []
	for value in design_objects.values():
		result.append(value as DesignObject)
	return result

func remove_object(id: int):
	design_objects.erase(id)
	var edges: Array[int] = []
	for edge in design_objects.values():
		if edge.origin == id or edge.target == id:
			edges.append(edge.object_id)
			
	for edge_id in edges:
		design_objects.erase(edge_id)
	design_changed.emit()
