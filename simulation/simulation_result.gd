class_name SimulationResult extends Object

class SimulationState:
	var step: int
	var time: float
	var values: Dictionary

	func _init(step: int, time: float, values: Dictionary):
		self.step = step
		self.time = time
		self.values = values
	
	func object_value(id: int) -> float:
		return values[id] as float

var states: Array[SimulationState] = []

var steps_computed: int:
	get:
		return len(states)

var last_state: SimulationState:
	get:
		return states[len(states) - 1]

func append_state(state: SimulationState):
	states.append(state)
	
func get_state(step: int):
	return states[step]
	
func object_value(step: int, id: int) -> float:
	var state = states[step]
	return state.object_value(id)
