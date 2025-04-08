class_name ResultChartItem extends PanelContainer

@onready var chart: Chart = %Chart
@onready var chart_label: Label = %ChartLabel

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_delete_button_pressed():
	# FIXME: Once this is a proper chart, then use the controller to remove the chart and then update the parent
	self.queue_free()
