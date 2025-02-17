class_name ObjectType extends Object

enum Structure { UNSTRUCTURED, NODE, EDGE }

@export var name: String
@export var traits: Array[String]
@export var structure: Structure


func _init(name: String, traits: Array[String], structure: Structure):
	self.name = name
	self.traits = traits
	self.structure = structure
