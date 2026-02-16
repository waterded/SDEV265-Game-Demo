extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_viewport().size_changed.connect(_on_viewport_size_changed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_viewport_size_changed() -> void:
	queue_redraw()

func _draw() -> void:
	var viewport_size = get_viewport_rect().size
	draw_circle(Vector2.ZERO, viewport_size.y/10, Color.ALICE_BLUE)
	pass