extends CenterContainer

const SLOT_SIZE := Vector2(64, 64)
const ICON_SIZE := Vector2(48, 48)

var _bg: TextureRect
var _icon: TextureRect

func _ready() -> void:
	_bg = $Background
	_icon = $Icon

func update_item(item: ItemTemplate) -> void:
	if item and item.icon:
		_icon.texture = item.icon
	else:
		_icon.texture = null
