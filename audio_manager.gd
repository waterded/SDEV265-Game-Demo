# Loops background music by restarting on finish
extends AudioStreamPlayer

func _on_finished() -> void:
	play()