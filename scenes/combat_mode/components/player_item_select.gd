extends HBoxContainer

signal item_selected(item: ItemTemplate)

var items: Array = []
var selected_index: int = -1
var _slots: Array[Control] = []
var _enabled: bool = false

const SLOT_SIZE := Vector2(64, 64)
const ICON_SIZE := Vector2(48, 48)
const UNSELECTED_MODULATE := Color(0.4, 0.4, 0.4, 1.0)
const SELECTED_MODULATE := Color(1.0, 0.3, 0.3, 1.0)

func setup(player_items: Array) -> void:
	items = player_items
	_build_slots()

func set_enabled(enabled: bool) -> void:
	_enabled = enabled
	for slot in _slots:
		if slot.visible:
			slot.mouse_filter = Control.MOUSE_FILTER_STOP if enabled else Control.MOUSE_FILTER_IGNORE

func _build_slots() -> void:
	for child in get_children():
		child.queue_free()
	_slots.clear()
	selected_index = -1

	for i in range(3):
		var slot := _create_slot(i)
		add_child(slot)
		_slots.append(slot)
		if i < items.size():
			_populate_slot(slot, items[i])
		else:
			slot.visible = false

func _create_slot(index: int) -> Control:
	var slot := Control.new()
	slot.custom_minimum_size = SLOT_SIZE
	slot.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	slot.mouse_filter = Control.MOUSE_FILTER_STOP if _enabled else Control.MOUSE_FILTER_IGNORE

	# Background texture
	var bg := TextureRect.new()
	bg.name = "Background"
	bg.texture = load("res://assets/item_fram.png")
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	bg.self_modulate = UNSELECTED_MODULATE
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	slot.add_child(bg)

	# Item icon overlay
	var icon := TextureRect.new()
	icon.name = "Icon"
	icon.custom_minimum_size = ICON_SIZE
	icon.size = ICON_SIZE
	icon.position = (SLOT_SIZE - ICON_SIZE) / 2.0
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	slot.add_child(icon)

	slot.gui_input.connect(_on_slot_input.bind(index))
	return slot

func _populate_slot(slot: Control, item: ItemTemplate) -> void:
	var icon: TextureRect = slot.get_node("Icon")
	if item.icon:
		icon.texture = item.icon
	slot.tooltip_text = item.display_name

func _on_slot_input(event: InputEvent, index: int) -> void:
	if not _enabled:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if index < items.size():
			_select(index)

func _select(index: int) -> void:
	selected_index = index
	_update_visuals()
	item_selected.emit(items[index])

func _update_visuals() -> void:
	for i in range(_slots.size()):
		if not _slots[i].visible:
			continue
		var bg: TextureRect = _slots[i].get_node("Background")
		if i == selected_index:
			bg.self_modulate = SELECTED_MODULATE
		else:
			bg.self_modulate = UNSELECTED_MODULATE
