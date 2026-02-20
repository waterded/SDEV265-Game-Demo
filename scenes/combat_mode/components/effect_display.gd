@tool
class_name EffectDisplay
extends HBoxContainer

# Maps Effect.Type to the label node showing its count
var _effect_labels: Dictionary = {}

const EFFECT_NAMES: Dictionary = {
	Effect.Type.DAMAGE: "DAMAGE",
	Effect.Type.ARMOR: "ARMOR",
	Effect.Type.NEGATE: "NEGATE",
	Effect.Type.BLOCK: "BLOCK",
	Effect.Type.POISON: "POISON",
	Effect.Type.STUN: "STUN",
	Effect.Type.CURSE: "CURSE",
	Effect.Type.LUCK: "LUCK",
	Effect.Type.ROLL_AGAIN: "ROLL AGAIN",
	Effect.Type.MULTIPLY_NEXT: "MULTIPLY",
	Effect.Type.HEAL: "HEAL",
	Effect.Type.NOTHING: "---",
}

func setup(combatant: Combatant) -> void:
	if Engine.is_editor_hint():
		return
	combatant.effect_changed.connect(_on_effect_changed)
	# Initialize from current effects
	for effect in combatant.cur_effects:
		_on_effect_changed(effect, combatant.cur_effects[effect])

func _on_effect_changed(effect: Effect.Type, new_amount: int) -> void:
	if Engine.is_editor_hint():
		return
	if new_amount == 0:
		# Remove the display for this effect
		if _effect_labels.has(effect):
			_effect_labels[effect].queue_free()
			_effect_labels.erase(effect)
		return

	if not _effect_labels.has(effect):
		# Create a new effect badge
		var badge := _create_badge(effect)
		add_child(badge)
		_effect_labels[effect] = badge

	# Update the count text
	var badge: PanelContainer = _effect_labels[effect]
	var label: Label = badge.get_node("Label")
	var effect_name: String = EFFECT_NAMES.get(effect, "???")
	label.text = "%s %d" % [effect_name, new_amount]

func _create_badge(effect: Effect.Type) -> PanelContainer:
	var panel := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = _get_effect_color(effect)
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	style.content_margin_left = 6
	style.content_margin_right = 6
	style.content_margin_top = 2
	style.content_margin_bottom = 2
	panel.add_theme_stylebox_override("panel", style)

	var label := Label.new()
	label.name = "Label"
	label.add_theme_font_size_override("font_size", 12)
	label.add_theme_color_override("font_color", Color.WHITE)
	panel.add_child(label)

	panel.custom_minimum_size = Vector2(50, 20)
	return panel

func _get_effect_color(effect: Effect.Type) -> Color:
	match effect:
		Effect.Type.DAMAGE: return Color(0.8, 0.2, 0.2, 0.8)
		Effect.Type.ARMOR: return Color(0.5, 0.5, 0.6, 0.8)
		Effect.Type.NEGATE: return Color(0.6, 0.4, 0.8, 0.8)
		Effect.Type.BLOCK: return Color(0.3, 0.4, 0.7, 0.8)
		Effect.Type.POISON: return Color(0.3, 0.7, 0.2, 0.8)
		Effect.Type.STUN: return Color(0.8, 0.7, 0.2, 0.8)
		Effect.Type.CURSE: return Color(0.5, 0.1, 0.5, 0.8)
		Effect.Type.LUCK: return Color(0.2, 0.7, 0.8, 0.8)
		Effect.Type.ROLL_AGAIN: return Color(0.8, 0.5, 0.2, 0.8)
		Effect.Type.MULTIPLY_NEXT: return Color(0.9, 0.3, 0.6, 0.8)
		Effect.Type.HEAL: return Color(0.2, 0.8, 0.4, 0.8)
		_: return Color(0.4, 0.4, 0.4, 0.8)
