# Shows the enemy's current attack item icon
extends CenterContainer

const SLOT_SIZE := Vector2(64, 64)
const ICON_SIZE := Vector2(48, 48)

var _bg: TextureRect
var _icon: TextureRect

# Cache child node references
func _ready() -> void:
	_bg = $Background
	_icon = $Icon

# Update the displayed icon and tooltip for the enemy's item
func update_item(item: ItemTemplate) -> void:
	if item and item.icon:
		_icon.texture = item.icon
		tooltip_text = item.display_name
	else:
		_icon.texture = null
		tooltip_text = ""
