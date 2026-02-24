@tool
class_name ProbabilityBar
extends Control

var item: ItemTemplate:
	set(value):
		item = value
		queue_redraw()

var spinner_position: float = -1.0  # -1 means hidden, 0.0–1.0 is normalized position

const BAR_RADIUS: float = 12.0
const BAR_HEIGHT: float = 32.0
const SPINNER_WIDTH: float = 4.0

func set_spinner(pos: float) -> void:
	if Engine.is_editor_hint():
		return
	spinner_position = pos
	queue_redraw()

func hide_spinner() -> void:
	if Engine.is_editor_hint():
		return
	spinner_position = -1.0
	queue_redraw()

func _draw() -> void:
	if item == null or item.effect_groups.is_empty():
		# Draw empty bar
		var rect := Rect2(Vector2.ZERO, Vector2(size.x, BAR_HEIGHT))
		draw_rect(rect, Color(0.15, 0.15, 0.15), true)
		return

	var total_weight: int = 0
	for group in item.effect_groups:
		total_weight += group.weight

	if total_weight <= 0:
		return

	# Draw each segment using clipping with a rounded rect
	var bar_rect := Rect2(Vector2.ZERO, Vector2(size.x, BAR_HEIGHT))

	# First draw the full rounded background so corners are clean
	draw_rect(bar_rect, Color(0.15, 0.15, 0.15), true)

	# Draw colored segments — we clip them visually by drawing over a rounded mask
	var x_offset: float = 0.0
	for i in range(item.effect_groups.size()):
		var group: EffectGroup = item.effect_groups[i]
		var segment_width: float = (float(group.weight) / float(total_weight)) * size.x
		var segment_rect := Rect2(Vector2(x_offset, 0), Vector2(segment_width, BAR_HEIGHT))
		draw_rect(segment_rect, group.color, true)
		x_offset += segment_width

		# Draw segment divider lines
	x_offset = 0.0
	for i in range(item.effect_groups.size() - 1):
		var group: EffectGroup = item.effect_groups[i]
		var segment_width: float = (float(group.weight) / float(total_weight)) * size.x
		x_offset += segment_width
		draw_line(
			Vector2(x_offset, 0),
			Vector2(x_offset, BAR_HEIGHT),
			Color(0.0, 0.0, 0.0, 0.5),
			2.0
		)

	# Draw spinner indicator
	if spinner_position >= 0.0:
		var sx: float = clampf(spinner_position, 0.0, 1.0) * size.x
		draw_line(
			Vector2(sx, -4),
			Vector2(sx, BAR_HEIGHT + 4),
			Color.WHITE,
			SPINNER_WIDTH
		)
		# Draw small triangle at top
		var tri_size: float = 6.0
		var tri := PackedVector2Array([
			Vector2(sx - tri_size, -4),
			Vector2(sx + tri_size, -4),
			Vector2(sx, tri_size - 4),
		])
		draw_colored_polygon(tri, Color.WHITE)

func _get_tooltip(at_position: Vector2) -> String:
	if item == null or item.effect_groups.is_empty():
		return ""

	var total_weight: int = 0
	for group in item.effect_groups:
		total_weight += group.weight

	if total_weight <= 0:
		return ""

	var x_offset: float = 0.0
	for group: EffectGroup in item.effect_groups:
		var segment_width: float = (float(group.weight) / float(total_weight)) * size.x
		if at_position.x < x_offset + segment_width:
			return _build_group_tooltip(group, total_weight)
		x_offset += segment_width

	return ""

func _build_group_tooltip(group: EffectGroup, total_weight: int) -> String:
	var pct: int = int(round(float(group.weight) / float(total_weight) * 100.0))
	var lines: PackedStringArray = ["%s  (%d/%d — %d%%)" % [group.label, group.weight, total_weight, pct]]
	for effect_type: int in group.effects:
		var amount: int = group.effects[effect_type]
		if item.rarity == -1 and effect_type == Effect.Type.DAMAGE:
			amount = max((amount * GameData.difficulty) / 100, 1)
		lines.append("  • " + _describe_effect(effect_type, amount))
	return "\n".join(lines)

func _describe_effect(effect_type: int, amount: int) -> String:
	match effect_type:
		Effect.Type.DAMAGE:        return "Deal %d damage to target" % amount
		Effect.Type.ARMOR:         return "Gain %d armor" % amount
		Effect.Type.NEGATE:        return "Negate %d incoming hit(s)" % amount
		Effect.Type.BLOCK:         return "Block %d damage" % amount
		Effect.Type.POISON:        return "Poison target for %d stack(s)" % amount
		Effect.Type.STUN:          return "Stun target for %d turn(s)" % amount
		Effect.Type.CURSE:         return "Curse target (-%d luck)" % amount
		Effect.Type.LUCK:          return "Gain %d luck" % amount
		Effect.Type.ROLL_AGAIN:    return "Roll again %d time(s)" % amount
		Effect.Type.MULTIPLY_NEXT: return "Multiply next effect by %d" % amount
		Effect.Type.HEAL:          return "Heal %d HP" % amount
		Effect.Type.NOTHING:       return "Nothing happens"
		_:                         return "Unknown effect"
