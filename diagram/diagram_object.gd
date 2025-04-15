class_name DiagramObject extends Node2D

@export var object_id: int
@export var type_name: String 
var object_name: Variant # String

@export var has_issues: bool = false:
	set(value):
		has_issues = value
		if issues_indicator:
			issues_indicator.visible = has_issues

@export var issues_indicator: Node2D
var default_issues_indicator_size: float = 10.0
var default_issues_indicator_offset: Vector2 = Vector2(0, -10)

@export var is_selected: bool = false:
	set(value):
		is_selected = value
		update_selection()
		queue_redraw()

func update_selection():
	pass

func _set_design_object(object: PoieticObject):
	if self.object_id:
		push_warning("Design object is already set")
	self.object_id = object.object_id
	if self.type_name:
		assert(self.type_name == object.type_name, "Object type changes are not (yet) permitted")
	self.type_name = object.type_name
	self._update_from_design_object(object)
	
## Update the diagram object from a design object.
func _update_from_design_object(object: PoieticObject):
	# Add custom implementation to the subclasses
	pass

func contains_point(point: Vector2) -> bool:
	return false

func handle_at_point(point: Vector2) -> Variant: # optional Handle
	return null

func bounding_box() -> Rect2:
	return Rect2()
	
## Get a list of handles that can be dragged when the object is selected.
##
func get_handles() -> Array[Handle]:
	return []
