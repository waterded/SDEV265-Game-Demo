extends Button

func _button_pressed():
	SceneRelay.play_button_sound()
	SceneRelay.change_scene(SceneRelay.DIFFICULTY_SELECT)