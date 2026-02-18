extends Button

func _on_pressed() -> void:
	GameData.difficulty = 125
	GameData.player_max_health = 40
	GameData.player_health = 40
	SceneRelay.play_button_sound()
	SceneRelay.change_scene(SceneRelay.COMBAT)