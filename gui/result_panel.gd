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

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_design_changed():
	pass

func _on_simulation_success(result):
	update_selection_chart(result)
	update_pinned_charts(result)
	
func _on_simulation_failed():
	# TODO: Godot does not seem to infer the player.result type correctly.
	update_selection_chart(player.result)
	
func _on_selection_changed(selection):
	# TODO: Godot does not seem to infer the player.result type correctly.
	update_selection_chart(player.result)

func update_selection_chart(result: PoieticResult):
	var chart: Chart = %SelectionChart
	chart.clear_series()

	if not result:
		return

	var ids = canvas.selection.get_ids()
	if ids:
		chart.series_ids = ids
	else:
		chart.series_ids = []
		
	update_chart(chart, result)

func update_pinned_charts(result: PoieticResult):
	var items = %ChartContainer.get_children()
	for item in items:
		if not item is ResultChartItem:
			return
		update_chart_item(item, result)

func update_chart_item(item: ResultChartItem, result: PoieticResult):
	update_chart(item.chart, result)
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

func update_chart(chart: Chart, result: PoieticResult) -> void:
	chart.clear_series()
	for id in chart.series_ids:
		var series = result.time_series(id)
		if not series:
			continue
		chart.append_series(series)

func _on_add_chart_button_pressed():
	var ids = canvas.selection.get_ids()
	if not ids:
		push_error("Result IDs are null")
		return
		
	var chart_item: ResultChartItem = load("res://gui/result_chart_item.tscn").instantiate()
	%ChartContainer.add_child(chart_item)
	var chart: Chart = chart_item.chart
	chart.custom_minimum_size.y = 200
	chart.add_to_group(&"live_charts")
	chart.series_ids = ids
	update_chart_item(chart_item, player.result)
