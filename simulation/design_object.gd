class_name DesignObject extends Object

enum StructureType { NODE, EDGE, UNSTRUCTURED, UNKNOWN }

var type_name: String
var structure: StructureType = StructureType.UNKNOWN
var object_id: int
var attributes: Dictionary
var origin: int
var target: int

static var _id_sequence: int = 1

func _init(type: String, name: String = "unnamed", position: Vector2 = Vector2(), value: float = 0.0) -> void:
	object_id = _id_sequence
	_id_sequence += 1
	self.type_name = type
	self.attributes = {
		"name": name,
		"value": value,
		"position": position,
	}
	
	match type_name:
		"Stock", "Flow", "Auxiliary", "GraphicalFunction", "Delay", "Smooth":
			structure = StructureType.NODE
		"Fills", "Drains", "Parameter": structure = StructureType.EDGE
		_: structure = StructureType.UNKNOWN

	print("New object id: ", object_id, " type: ", type_name, " struct: ", structure)

func get_name() -> String:
	return attributes.get("name", "")

func set_name(new_value: String) -> void:
	attributes["name"] = new_value

func get_value() -> float:
	return attributes.get("value", 0.0)

func set_value(new_value: float) -> void:
	attributes["value"] = new_value

func update_attribute(key: String, value: Variant) -> void:
	attributes[key] = value

func attribute(key: String) -> Variant:
	return attributes[key]
