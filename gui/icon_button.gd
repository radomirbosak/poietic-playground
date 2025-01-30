class_name IconButton extends TextureButton

var shader: Shader = preload("res://resources/button_icon.gdshader")
var shader_material: ShaderMaterial

func _init():
	shader_material = ShaderMaterial.new()
	shader_material.shader = shader

func _ready():
	# Ensure the shader material is assigned
	material = shader_material

func _pressed():
	pass

func _toggled(button_pressed: bool):
	update_shader()

func update_shader():
	shader_material.set_shader_parameter("is_selected", button_pressed)
