extends Button

# Set easy difficulty stats and start combat
func _on_pressed() -> void:
	GameData.difficulty = 75
	GameData.player_max_health = 60
	GameData.player_health = 60
	SceneRelay.play_button_sound()
	SceneRelay.change_scene(SceneRelay.COMBAT)