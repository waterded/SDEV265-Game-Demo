# Toggle button that mutes/unmutes the master audio bus
extends TextureButton

func _ready() -> void:
	var master_bus_index = AudioServer.get_bus_index("Master")
	button_pressed = AudioServer.is_bus_mute(master_bus_index)

# Mute or unmute audio based on toggle state
func _on_toggled(toggled_on: bool) -> void:
	var master_bus_index = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_mute(master_bus_index, toggled_on)