class_name ObjectPalette extends PanelContainer

signal place_object(Vector2, String)

@onready var item_grid: GridContainer = %ItemGrid

var callout_position: Vector2 = Vector2()

enum TriangleSide {
	TOP,
	BOTTOM,
	LEFT,
	RIGHT
}

@export var target_point: Vector2 = Vector2(0, 0)
@export var triangle_side: TriangleSide = TriangleSide.TOP  # Use the enum
const corner_radius: float = 10.0
const triangle_size: float = 20.0
const triangle_height: float = sqrt(3.) / 2.0 * triangle_size
const padding: float = 10.0

class ObjectPaletteItem extends TextureButton:
	var pictogram: Pictogram

	func _init(pictogram: Pictogram):
		self.pictogram = pictogram
		self.texture_normal = pictogram.get_texture()
		self.ignore_texture_size = true
		self.stretch_mode = StretchMode.STRETCH_KEEP_ASPECT_CENTERED

func _ready():
	call_deferred("update_items")

func update_items():
	item_grid = %ItemGrid
	for child in item_grid.get_children():
		item_grid.remove_child(child)
		
	for pictogram in Pictogram._internal_pictograms:
		add_item(pictogram)

func add_item(pictogram: Pictogram):
	var item: ObjectPaletteItem = ObjectPaletteItem.new(pictogram)
	item.custom_minimum_size = Vector2(60, 60)
	item.pressed.connect(_on_item_selected.bind(item))
	item_grid.add_child(item)
	queue_redraw()

func _on_item_selected(item: ObjectPaletteItem):
	place_object.emit(callout_position, item.pictogram.name)
	
func set_callout_position(callout_position: Vector2):
	self.callout_position = callout_position
	var viewport_size: Vector2 = get_viewport_rect().size
	var grid_x: int = int((callout_position.x / viewport_size.x) * 3)
	var grid_y: int = int((callout_position.y / viewport_size.y) * 3)
	if grid_x == 0:  # Top-left
		triangle_side = TriangleSide.LEFT
	elif grid_x == 2 :  # Top-right
		triangle_side = TriangleSide.RIGHT
	elif grid_x == 1 and grid_y == 0:  # Top-center
		triangle_side = TriangleSide.TOP
	elif grid_x == 1 and grid_y == 2:  # Bottom-center
		triangle_side = TriangleSide.BOTTOM
	elif grid_x == 1 and grid_y == 1:  # Center
		triangle_side = TriangleSide.TOP
	elif grid_x == 2 and grid_y == 1:  # Center-right
		triangle_side = TriangleSide.RIGHT
	else:
		triangle_side = TriangleSide.TOP  # Default

	match triangle_side:
		TriangleSide.TOP:
			position = callout_position + Vector2(-size.x / 2, +size.y/2 - triangle_height)
		TriangleSide.BOTTOM:
			position = callout_position + Vector2(-size.x / 2, -size.y - triangle_height)
		TriangleSide.LEFT:
			position = callout_position + Vector2(0 + triangle_height, - size.y / 2)
		TriangleSide.RIGHT:
			position = callout_position + Vector2(-size.x - triangle_height, -size.y / 2)
	queue_redraw()

func _draw():
	# Draw the bubble with rounded corners and a triangle
	draw_bubble()

func draw_bubble():
	var rect = Rect2(Vector2.ZERO, self.size)
	var cut_point = Vector2.ZERO

	# Adjust the position of the rectangle based on the triangle side
	match triangle_side:
		TriangleSide.TOP:
			cut_point = Vector2(self.size.x / 2, 0)
		TriangleSide.BOTTOM:
			cut_point = Vector2(self.size.x / 2, self.size.y)
		TriangleSide.LEFT:
			cut_point = Vector2(0, self.size.y / 2)
		TriangleSide.RIGHT:
			cut_point = Vector2(self.size.x, self.size.y / 2)

	# Draw the rounded rectangle
	draw_rect(rect, Color.BLACK)

	# Draw the triangle
	var a: Vector2
	var b: Vector2
	var c: Vector2
	var triangle = PackedVector2Array()
	match triangle_side:
		TriangleSide.TOP:
			a = cut_point - Vector2(+triangle_size, 0)
			b = cut_point - Vector2(-triangle_size, 0)
			c = a + (a - b).rotated(90)
		TriangleSide.BOTTOM:
			a = cut_point - Vector2(-triangle_size, 0)
			b = cut_point - Vector2(+triangle_size, 0)
			c = a + (a - b).rotated(90)
		TriangleSide.LEFT:
			a = cut_point - Vector2(0, -triangle_size)
			b = cut_point - Vector2(0, +triangle_size)
			c = a + (a - b).rotated(90)
		TriangleSide.RIGHT:
			a = cut_point - Vector2(0, -triangle_size)
			b = cut_point - Vector2(0, +triangle_size)
			c = a + (a - b).rotated(-90)
	triangle.append(a)
	triangle.append(b)
	triangle.append(c)
	triangle.append(a)

	var bubble = PackedVector2Array()

	match triangle_side:
		TriangleSide.TOP:
			bubble = [Vector2(0, 0), a, c, b,
			   		  Vector2(size.x, 0),
					  Vector2(size.x, size.y),
					  Vector2(0, size.y),
					  Vector2(0, 0)]
		TriangleSide.BOTTOM:
			bubble = [Vector2(0, 0),
					  Vector2(size.x, 0),
					  Vector2(size.x, size.y), a, c, b,
					  Vector2(0, size.y),
					  Vector2(0, 0)]
		TriangleSide.LEFT:
			bubble = [Vector2(0, 0),
					  Vector2(size.x, 0),
					  Vector2(size.x, size.y), 
					  Vector2(0, size.y), a, c, b,
					  Vector2(0, 0)]
		TriangleSide.RIGHT:
			bubble = [Vector2(0, 0),
					  Vector2(size.x, 0),  b, c, a,
					  Vector2(size.x, size.y),
					  Vector2(0, size.y),
					  Vector2(0, 0)]


	draw_polyline(bubble, Color.WHITE, 4.0)

	# Adjust the position of the control to align the triangle tip with the target point
	#match triangle_side:
		#TriangleSide.TOP:
			#position = target_point - Vector2(rect.size.x / 2, triangle_size.y)
		#TriangleSide.BOTTOM:
			#position = target_point - Vector2(rect.size.x / 2, rect.size.y)
		#TriangleSide.LEFT:
			#position = target_point - Vector2(triangle_size.y, rect.size.y / 2)
		#TriangleSide.RIGHT:
			#position = target_point - Vector2(rect.size.x, rect.size.y / 2)

	# Add padding for the content
	rect.position += Vector2(padding, padding)
	rect.size -= Vector2(padding * 2, padding * 2)
