class_name Pictogram extends Object

const placeable_nodes = ["Stock", "FlowRate", "Auxiliary", "GraphicalFunction", "Smooth", "Delay"]

const tile_size = 50
const default_image_scale = 1.7

static var _all_pictograms: Dictionary = {}
static var default_pictogram: Pictogram

var name: String
var shape: Shape2D
var svg_buffer: PackedByteArray
var offset: Vector2 = Vector2()

# enum Flags { FLIP_HORIZONTALLY, FLIP_VERTICALLY, ROTATE }
# enum Orientation { NORTH, EAST, SOUTH, WEST }

var magnets: Array[Magnet]

class Magnet:
	var name: String
	var position: Vector2


static func _load_pictograms():
	# TODO: Adjust the scales based on the rules for the pictogram sizes (not yet defined)
	var circle = CircleShape2D.new()
	circle.radius = Pictogram.tile_size / Pictogram.default_image_scale
	var square = RectangleShape2D.new()
	square.size = Vector2(Pictogram.tile_size, Pictogram.tile_size)
	var rectangle = RectangleShape2D.new()
	rectangle.size = Vector2(Pictogram.tile_size * 3, Pictogram.tile_size * 2)
	var flow_shape = CircleShape2D.new()
	flow_shape.radius = Pictogram.tile_size * 0.8
	
	_all_pictograms.clear()
	
	default_pictogram = Pictogram.new("Unknown", square)
	_all_pictograms["default"] = default_pictogram
	var pictograms: Array[Pictogram]= [
		Pictogram.new("Stock", rectangle),
		Pictogram.new("FlowRate", flow_shape),
		Pictogram.new("Auxiliary", circle),
		Pictogram.new("GraphicalFunction", circle),
		Pictogram.new("Smooth", square),
		Pictogram.new("Delay", square)
	]
	for pictogram in pictograms:
		_all_pictograms[pictogram.name] = pictogram
		
	# TODO: Aliases
	# _all_pictograms["FlowRate"] = _all_pictograms["Flow"]
	

static func get_pictogram(name: String) -> Pictogram:
	var pictogram = _all_pictograms.get(name)
	if pictogram:
		return pictogram
	else:
		push_warning("Unknown pictogram: ", name)
		return default_pictogram


static func get_placeable_pictograms() -> Array[Pictogram]:
	var result: Array[Pictogram]
	for name in Global.metamodel.get_type_list_with_trait("DiagramNode"):
		result.append(get_pictogram(name))
	return result


func _init(name: String, shape: Shape2D, magnets: Array[Magnet] = []):
	self.name = name
	self.shape = shape
	self.magnets = magnets
	var path = "res://resources/pictograms/" + name + ".svg"
	self.svg_buffer = FileAccess.get_file_as_bytes(path)



func get_image(scale: float = default_image_scale) -> Image:
	var image = Image.new()
	if image.load_svg_from_buffer(svg_buffer, scale) == OK:
		for x in range(0, image.get_width()):
			for y in range(0, image.get_height()):
				var pixel = image.get_pixel(x, y)
				image.set_pixel(x, y, pixel.inverted())
	return image	

func get_texture(scale: float = default_image_scale) -> ImageTexture:
	return ImageTexture.create_from_image(get_image(scale))

func get_magnet(name: String) -> Magnet:
	for magnet in magnets:
		if magnet.name == name:
			return magnet
	return null
	
func nearest_magnet(point: Vector2) -> Magnet:
	var offset_point = point + offset
	var nearest: Magnet = null
	var min_dist: float = 0.0
	for i in range(len(magnets)):
		var magnet = magnets[i]
		var dist = magnet.position.distance_to(point)
		if not min_dist:
			min_dist = dist
			nearest = magnet
		elif dist < min_dist:
			min_dist = dist
			nearest = magnet
	return nearest

func nearest_connection(point: Vector2) -> Vector2:
	if magnets and len(magnets) > 0:
		var magnet = nearest_magnet(point)
		return magnet.position
	else:
		return Vector2()
