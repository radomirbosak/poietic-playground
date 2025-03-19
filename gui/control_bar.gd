class_name ControlBar extends PanelContainer

@onready var reset_button: TextureButton = %ResetButton
@onready var stop_button: TextureButton = %StopButton
@onready var run_button: TextureButton = %RunButton
@onready var loop_button: TextureButton = %LoopButton
@onready var time_label: Label = %Time
@onready var end_time_field: LineEdit = %EndTimeField

func update_simulator_state():
	if Global.player.is_running:
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
		
	loop_button.set_pressed_no_signal(Global.player.is_looping)
	loop_button.update_shader()
	time_label.text = str(Global.player.current_step)

func _on_simulation_success(result: PoieticResult):
	end_time_field.text = str(result.end_time)
	
func _on_simulation_failure():
	pass

func _on_simulator_started():
	update_simulator_state()

func _on_simulator_step():
	update_simulator_state()
	
func _on_simulator_stopped():
	update_simulator_state()

func _on_reset_pressed():
	Global.player.stop()
	Global.player.restart()
	update_simulator_state()

func _on_run_pressed():
	if Global.player.is_running:
		return
	Global.player.run()

func _on_stop_button_pressed():
	if !Global.player.is_running:
		return
	Global.player.stop()


func _on_loop_button_pressed():
	Global.player.is_looping = loop_button.button_pressed
	update_simulator_state()
