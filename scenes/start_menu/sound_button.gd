extends TextureButton

func _ready() -> void:
	# Initialize button state based on current audio state
	var master_bus_index = AudioServer.get_bus_index("Master")
	button_pressed = AudioServer.is_bus_mute(master_bus_index)

func _on_toggled(toggled_on: bool) -> void:
	# Get the Master bus index
	var master_bus_index = AudioServer.get_bus_index("Master")

	# When toggled_on is true, mute the audio (button is pressed/crossed out)
	# When toggled_on is false, unmute the audio (button is normal)
	AudioServer.set_bus_mute(master_bus_index, toggled_on)