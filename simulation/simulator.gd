class_name Simulator extends Node

## Signal sent when simulation is run.
signal simulation_started()

## Signal sent when simulation is stopped.
signal simulation_stopped()

signal simulation_step()
signal simulation_reset()

var is_running: bool = false
var time_to_step: float = 0
var step_duration: float = 0.5

var step: int = 1
var time: float = 0.0
var time_delta: float = 1.0
	
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_running:
		if time_to_step <= 0:
			run_step()
			time_to_step = step_duration
		else:
			time_to_step -= delta
			# print("Remaining: ", time_to_step)
	
func run_step():
	print("Step ", step)
	step += 1
	simulation_step.emit()

func run():
	is_running = true
	simulation_started.emit()
	
func stop():
	is_running = false
	simulation_stopped.emit()

func reset():
	step = 0
	
