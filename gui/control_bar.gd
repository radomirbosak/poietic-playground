class_name ControlBar extends PanelContainer

@onready var run_stop_button: Button = %RunStopButton
@onready var time_label: Label = %Time
@onready var steps_label: Label = %StepsLabel

func _ready():
	GlobalSimulator.simulation_started.connect(_on_simulator_started)
	GlobalSimulator.simulation_stopped.connect(_on_simulator_stopped)
	GlobalSimulator.simulation_step.connect(_on_simulator_step)
	GlobalSimulator.simulation_reset.connect(_on_simulator_step)

func _on_simulator_started():
	run_stop_button.text = "Stop"
	
func _on_simulator_step():
	time_label.text = str(GlobalSimulator.step)

func _on_simulator_stopped():
	run_stop_button.text = "Run"

func _on_reset_pressed():
	GlobalSimulator.stop()
	GlobalSimulator.reset()

func _on_run_pressed():
	if GlobalSimulator.is_running:
		GlobalSimulator.stop()
	else:
		GlobalSimulator.run()
	pass # Replace with function body.
