# Displays the current viewport size, updated every frame
extends RichTextLabel

func _ready() -> void:
	update_viewport_size()

func _process(_delta: float) -> void:
	update_viewport_size()

# Update the label text with current viewport dimensions
func update_viewport_size() -> void:
	var viewport_size = get_viewport_rect().size
	text = "Viewport Size: %d x %d" % [viewport_size.x, viewport_size.y]
