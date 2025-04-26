class_name ResultPanel extends Node

# TODO: Use group "live_charts" for chart nodes for updating

@export var design_ctrl: PoieticDesignController
@export var player: PoieticPlayer
@export var canvas: DiagramCanvas

@export var result_panel: Node

func initialize(design_ctrl: PoieticDesignController, player: PoieticPlayer, canvas: DiagramCanvas):
	self.design_ctrl = design_ctrl
	self.player = player
	self.canvas = canvas
	
	design_ctrl.simulation_finished.connect(_on_simulation_success)
	design_ctrl.simulation_failed.connect(_on_simulation_failed)
	canvas.selection.selection_changed.connect(_on_selection_changed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_design_changed():
	pass

func _on_simulation_success(result):
	update_pinned_charts(result)
	
func _on_simulation_failed():
	pass
	
func _on_selection_changed(selection):
	pass

func update_pinned_charts(result: PoieticResult):
	var items = %ChartContainer.get_children()
	for item in items:
		if not item is ResultChartItem:
			return
		update_chart_item(item, result)

func update_chart_item(item: ResultChartItem, result: PoieticResult):
	item.chart.update_from_result(result)
	var names: Array[String] = []
	for id in item.chart.series_ids:
		var object: PoieticObject = design_ctrl.get_object(id)
		if not object:
			continue
		var name = object.object_name
		if not name:
			name = "unknown"
		names.append(name)
	if names.is_empty():
		item.chart_label.text = "(empty)"
	else:
		item.chart_label.text = ", ".join(names)

func _on_add_chart_button_pressed():
	var ids = canvas.selection.get_ids()
	if not ids:
		push_error("Result IDs are null")
		return
		
	var chart_item: ResultChartItem = load("res://gui/result_chart_item.tscn").instantiate()
	%ChartContainer.add_child(chart_item)
	var chart: Chart = chart_item.chart
	chart.custom_minimum_size.x = 300
	chart.custom_minimum_size.y = 200
	chart.add_to_group(&"live_charts")
	chart.series_ids = ids
	update_chart_item(chart_item, player.result)
