extends Node2D

enum Tool {
	SELECT = 0,
	CONNECT = 1,
}

var current_tool: Tool = Tool.SELECT


# Called when the node enters the scene tree for the first time.
func _ready():
	print("Current tool: ", current_tool)
	$DiagramCanvas.add_node(Vector2(100, 100))
	$DiagramCanvas.add_node(Vector2(220, 150))


func _input(event):
	if event.is_action_pressed("connect-tool"):
		set_tool(Tool.CONNECT)
	elif event.is_action_pressed("selection-tool"):
		set_tool(Tool.SELECT)

	elif event.is_action_pressed("add-node"):
		var mouse_position = get_viewport().get_mouse_position()
		var position = $DiagramCanvas.to_local(mouse_position)
		$DiagramCanvas.add_node(position)

	elif event.is_action_pressed("delete"):
		print("Delete (not yet)")

		

func set_tool(tool: Tool):
	print("Use tool: ", tool)
	self.current_tool = tool
