class_name ControlBar extends PanelContainer

@onready var reset_button: TextureButton = %ResetButton
@onready var stop_button: TextureButton = %StopButton
@onready var run_button: TextureButton = %RunButton
@onready var loop_button: TextureButton = %LoopButton
@onready var time_label: Label = %Time
@onready var steps_label: Label = %StepsLabel

func _ready():
	GlobalSimulator.simulation_started.connect(_on_simulator_started)
	GlobalSimulator.simulation_stopped.connect(_on_simulator_stopped)
	GlobalSimulator.simulation_step.connect(_on_simulator_step)
	GlobalSimulator.simulation_reset.connect(_on_simulator_step)
	update_simulator_state()

func update_simulator_state():
	if GlobalSimulator.is_running:
		run_button.set_pressed_no_signal(true)
		run_button.update_shader()
		run_button.disabled = true
		stop_button.set_pressed_no_signal(false)
		stop_button.update_shader()
		stop_button.disabled = false
	else:
		run_button.set_pressed_no_signal(false)
		run_button.update_shader()
		stop_button.set_pressed_no_signal(true)
		stop_button.update_shader()
		run_button.disabled = false
		stop_button.disabled = true
	time_label.text = str(GlobalSimulator.step)

func _on_simulator_started():
	update_simulator_state()

func _on_simulator_step():
	update_simulator_state()
	
func _on_simulator_stopped():
	update_simulator_state()

func _on_reset_pressed():
	GlobalSimulator.stop()
	GlobalSimulator.reset()
	update_simulator_state()

func _on_run_pressed():
	if GlobalSimulator.is_running:
		return
	GlobalSimulator.run()

func _on_stop_button_pressed():
	if !GlobalSimulator.is_running:
		return
	GlobalSimulator.stop()


func _on_loop_button_pressed():
	print("Loop button pressed (not implemented yet)")
