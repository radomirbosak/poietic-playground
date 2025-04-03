class_name CanvasPrompt extends Control

# TODO: Use this
#class Context:
	#var objetcs: PackedInt64Array
	#var attribute: String
	#var value: Variant

@export var canvas: DiagramCanvas
@export var prompt_manager: CanvasPromptManager

func initialize(canvas: DiagramCanvas, manager: CanvasPromptManager):
	self.canvas = canvas
	self.prompt_manager = manager
