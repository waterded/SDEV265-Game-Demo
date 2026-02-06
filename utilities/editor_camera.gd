@tool
extends Camera2D

func _ready():
    if not Engine.is_editor_hint():
        queue_free()  # Remove when game runs