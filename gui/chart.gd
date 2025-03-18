class_name Chart extends Control

var data: Array[TimeSeries] = []

# Styling
var x_axis: Axis = Axis.new()
var y_axis: Axis = Axis.new()
var x_axis_width: float = 20
var y_axis_width: float = 20

var data_rect: Rect2
# Scale from data to plot
# var data_scale: Vector2

var _plot_rect: Rect2

var series_scale: Vector2
var series_offset: Vector2

@export var x_axis_visible: bool:
	set(value):
		x_axis.visible = value
		_layout_plotting_area()

@export var y_axis_visible: bool:
	set(value):
		y_axis.visible = value
		_layout_plotting_area()
		
class Axis:
	var visible: bool = true
	var min: float # null for auto
	var max: float # null for auto
	var major_steps: float # null for auto
	var minor_steps: float # null for auto
	# reflines: avg, med, min, max, 
	var show_major: bool = true
	var show_minor: bool = false
	var line_color: Color = Color.WHITE
	
class TimeSeries:
	var time_min: float
	var time_delta: float
	var data_min: float
	var data_max: float
	var data: PackedFloat64Array:
		set = _set_data
	
	var time_max: float:
		get:
			return time_min + (len(data) - 1) * time_delta
	var count: int:
		get:
			return len(data)
			
	func _set_data(array: PackedFloat64Array):
		data = array
		if data.is_empty():
			data_min = 0
			data_max = 0
		else:
			data_min = data[0]
			data_max = data[0]
			for value in data:
				data_min = min(data_min, value)
				data_max = max(data_max, value)
			
	func get_offset() -> Vector2:
		return Vector2(self.time_min, self.data_min)

	func get_scale(size: Vector2) -> Vector2:
		return size / get_bounding_box().size

	func get_bounding_box() -> Rect2:
		return Rect2(Vector2(self.time_min, self.data_min),
					 Vector2(self.time_max - self.time_min, self.data_max - self.data_min))

func clear_series():
	data.clear()
	queue_redraw()

func append_series(series: TimeSeries):
	if self.data.is_empty():
		# Layout according to the first series in the list
		self.series_offset = series.get_offset()
		self.data_rect = series.get_bounding_box()

	self.data.append(series)
	queue_redraw()

func _create_demo_data():
	var data = [10, 40, 60,120,40,20,10,50,60,70]
	var real_data = PackedFloat64Array()
	for item in data:
		real_data.append(item * 100)
	var series = TimeSeries.new()
	series.data = real_data
	series.time_min = 100
	series.time_delta = 10
	self.append_series(series)

func _init():
	self.data = []

	minimum_size_changed.connect(self._layout_plotting_area)
	var x_axis = Axis.new()
	var y_axis = Axis.new()
	# _create_demo_data()

func _ready():
	_layout_plotting_area()

var plot_offset: Vector2 = Vector2()

func _draw():
	if data.is_empty():
		return
	_layout_plotting_area()
	var size = self.get_rect().size
	# draw_rect(self.get_rect(), Color.ORANGE, false)

	# draw_rect(_plot_rect, Color.ORANGE, false)
	_draw_grid()
	_draw_axes()
	for plot_series in data:
		_draw_line_plot(plot_series)

func _draw_axes():
	var bbox = self.get_rect()
	var plot_zero = Vector2(_plot_rect.position.x, _plot_rect.position.y + _plot_rect.size.y)
	# X-Axis
	var x_axis_rect = Rect2(_plot_rect.position.x, bbox.size.y-x_axis_width, _plot_rect.size.x, x_axis_width)
	draw_line(plot_zero, plot_zero + Vector2(x_axis_rect.size.x, 0), x_axis.line_color, 2.0)

	var y_axis_rect = Rect2(0, 0, y_axis_width, _plot_rect.size.y)
	draw_line(plot_zero, plot_zero + Vector2(0, -y_axis_rect.size.y), y_axis.line_color, 2.0)
	
func _draw_grid():
	var plot_zero = Vector2(_plot_rect.position.x, _plot_rect.position.y + _plot_rect.size.y)
	var series = data[0]

	var x_ticks = tick_marks(series.time_min, series.time_max, series.time_delta)
	for tick in x_ticks:
		var ptick = to_plot(Vector2(tick, series.data_min), _plot_rect.size)
		draw_line(ptick, ptick + Vector2(0, +10), x_axis.line_color)

	var y_ticks = tick_marks(series.data_min, series.data_max, (series.data_max - series.data_min) / 10)
	for tick in y_ticks:
		var ptick = to_plot(Vector2(series.time_min, tick), _plot_rect.size)
		draw_line(ptick, ptick - Vector2(+10, 0), y_axis.line_color)
	pass
	
func _draw_line_plot(plot_series: TimeSeries):
	var curve = screen_curve_for_series(plot_series, _plot_rect.size)
	var points = curve.tessellate()
	for index in range(0, len(points)):
		points[index] = points[index]

	draw_polyline(points, Color.WHITE, 4.0)
	
	
# Flips Y axis
func screen_curve_for_series(series: TimeSeries, size: Vector2) -> Curve2D:
	var curve: Curve2D = Curve2D.new()
	var time = series.time_min
	for value in series.data:
		var plot_point = to_plot(Vector2(time, value), size)
		# var flipped_point = Vector2(scaled_point.x, size.y - scaled_point.y)
		curve.add_point(plot_point)
		time += series.time_delta
	return curve

func _layout_plotting_area():
	plot_offset = Vector2(y_axis_width, 0)
	_plot_rect = Rect2(plot_offset, Vector2(size.x - y_axis_width, size.y - x_axis_width))
	
func to_plot(data_point: Vector2, size: Vector2) -> Vector2:
	var series_scale = self.data[0].get_scale(size)
	var point = (data_point - series_offset) * series_scale 
	var flipped_point = Vector2(point.x, size.y - point.y)
	# print("TO plot: ", series_scale, " xset: ", series_offset)
	return flipped_point + plot_offset

func tick_marks(min: float, max: float, step: float) -> PackedFloat32Array:
	var value = min
	var result = PackedFloat32Array()
	while value < max:
		result.append(value)
		value += step
	return result


func _process(delta):
	pass

func _data_changed():
	pass
