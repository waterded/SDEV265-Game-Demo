extends Button

func _ready() -> void:
	# Hide the button if not running in the editor
	if not OS.has_feature("editor"):
		visible = false



func _on_pressed() -> void:
	SceneRelay.play_button_sound()
	SceneRelay.change_scene(SceneRelay.RESOURCE_EDITOR)
