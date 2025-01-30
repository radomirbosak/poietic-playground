class_name Simulator extends Node

## Signal sent when simulation is run.
signal simulation_started()

## Signal sent when simulation is stopped.
signal simulation_stopped()

signal simulation_step()
signal simulation_reset()

var is_running: bool = false
var time_to_step: float = 0
var step_duration: float = 0.1

var step: int = 1
var time: float = 0.0
var time_delta: float = 1.0
var max_steps: int = 20
var is_looping: bool = true

var design: Design:
	set(value):
		design = value
		initialize_result()
		

var result: SimulationResult

func _init():
	design = Design.global
	initialize_result()
	
func _ready():
	pass

func _process(delta):
	if is_running:
		if time_to_step <= 0:
			run_step()
			time_to_step = step_duration
		else:
			time_to_step -= delta
	
func _on_design_changed():
	initialize_result()

func run_step():
	if step >= max_steps:
		if is_looping:
			step = 0
		else:
			stop()
			return

	if step >= result.steps_computed - 1:
		compute_next_step()

	step += 1
	simulation_step.emit()

func compute_next_step():
	print("Computing step ", step)
	var last_state: SimulationResult.SimulationState = result.last_state
	var values: Dictionary = {}
	for object in design.all_nodes():
		var value = last_state.object_value(object.object_id)
		if value != null:
			if value > 50:
				value += (randi() % 10) - 6
			else:
				value += (randi() % 10) - 4
			value = min(max(0, value), 100)
		values[object.object_id] = value

	var new_state = SimulationResult.SimulationState.new(step, step, values)
	result.append_state(new_state)

func run():
	is_running = true
	simulation_started.emit()
	
func stop():
	is_running = false
	simulation_stopped.emit()

func reset():
	initialize_result()
	
func initialize_result():
	step = 0
	if result != null:
		result.free()
	result = SimulationResult.new()
	var values: Dictionary = {}
	for object in design.all_nodes():
		var value = object.get_value()
		if value != null:
			values[object.object_id] = value
		else:
			values[object.object_id] = 0.0
	var state = SimulationResult.SimulationState.new(0, 0, values)
	print("Initialized result with ", len(values), " values")
	result.append_state(state)

func current_object_value(id: int) -> float:
	return result.object_value(step, id)
