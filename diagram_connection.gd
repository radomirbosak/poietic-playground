class_name DiagramConnection extends Node2D

var line: Line2D
var origin: DiagramNode
var target: Node2D

	
# Called when the node enters the scene tree for the first time.
func _ready():
	self.line = Line2D.new()
	self.line.name = "line"
	add_child(line)

@warning_ignore("shadowed_variable")
func set_connection(origin: DiagramNode, target: Node2D):
	self.origin = origin
	self.target = target
	update_shape()

@warning_ignore("shadowed_variable")
func set_target(target: DiagramNode):
	self.target = target
	update_shape()
	
func update_shape():
	if origin == null or target == null:
		push_warning("Updating connector shape without origin or target")
		return
	print("Update shape: ", origin.position, target.position)
	line.clear_points()
	
	line.add_point(origin.position)
	line.add_point(target.position)
