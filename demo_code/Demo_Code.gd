# Demo scene that draws a circle scaled to the viewport
extends Node2D

func _ready() -> void:
	get_viewport().size_changed.connect(_on_viewport_size_changed)

func _process(_delta: float) -> void:
	pass

# Redraw when the viewport resizes
func _on_viewport_size_changed() -> void:
	queue_redraw()

# Draw a circle at the origin sized relative to the viewport
func _draw() -> void:
	var viewport_size = get_viewport_rect().size
	draw_circle(Vector2.ZERO, viewport_size.y/10, Color.ALICE_BLUE)