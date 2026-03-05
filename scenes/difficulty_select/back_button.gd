extends Button

# Return to the start menu
func _on_pressed() -> void:
	SceneRelay.play_button_sound()
	SceneRelay.change_scene(SceneRelay.START_MENU)
