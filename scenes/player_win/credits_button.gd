extends Button

# Navigate to the credits screen
func _on_pressed() -> void:
	SceneRelay.play_button_sound()
	SceneRelay.change_scene(SceneRelay.CREDITS)
