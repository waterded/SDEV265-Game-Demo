extends Button

# Proceed to the next combat encounter
func _on_pressed() -> void:
	SceneRelay.play_button_sound()
	SceneRelay.change_scene(SceneRelay.COMBAT)
