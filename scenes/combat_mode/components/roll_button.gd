extends Button

signal roll_pressed

const COLOR_GRAY := Color(0.5, 0.5, 0.5, 1.0)
const COLOR_RED := Color(0.85, 0.15, 0.15, 1.0)

var rollable: bool = false:
	set(value):
		rollable = value
		disabled = not rollable
		if rollable:
			self_modulate = COLOR_RED
		else:
			self_modulate = COLOR_GRAY

func _ready() -> void:
	text = "ROLL"
	rollable = false
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	if rollable:
		roll_pressed.emit()
