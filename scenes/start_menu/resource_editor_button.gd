# Editor-only button that opens the resource editor
extends Button

# Hide when not running from the editor
func _ready() -> void:
	if not OS.has_feature("editor"):
		visible = false

# Navigate to the resource editor scene
func _on_pressed() -> void:
	SceneRelay.play_button_sound()
	SceneRelay.change_scene(SceneRelay.RESOURCE_EDITOR)
