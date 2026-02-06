extends RichTextLabel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_viewport_size()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	update_viewport_size()

func update_viewport_size() -> void:
	var viewport_size = get_viewport_rect().size
	text = "Viewport Size: %d x %d" % [viewport_size.x, viewport_size.y]
