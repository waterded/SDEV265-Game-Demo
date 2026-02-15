class_name ProbabilityBar
extends Control

var current_item: ItemTemplate = null
var needle_pos: float = 0.0  # 0.0–1.0

func set_item(item: ItemTemplate) -> void:
	current_item = item
	queue_redraw()

func set_needle(pos: float) -> void:
	needle_pos = pos
	queue_redraw()

func _draw() -> void:
	if not current_item or current_item.effect_groups.is_empty():
		draw_rect(Rect2(0, 0, size.x, size.y), Color(0.2, 0.2, 0.2))
		return

	var total_weight: int = 0
	for g in current_item.effect_groups:
		total_weight += g.weight
	if total_weight == 0:
		return

	var bar_w: float = size.x
	var bar_h: float = size.y
	var x: float = 0.0
	var font = ThemeDB.fallback_font
	var font_size: int = 14

	for i in current_item.effect_groups.size():
		var g: EffectGroup = current_item.effect_groups[i]
		var seg_w: float = (float(g.weight) / float(total_weight)) * bar_w

		# Segment background
		draw_rect(Rect2(x, 0.0, seg_w, bar_h), g.color)

		# Slightly darker border stripe between segments
		if i < current_item.effect_groups.size() - 1:
			draw_line(Vector2(x + seg_w, 0.0), Vector2(x + seg_w, bar_h), Color.BLACK, 2.0)

		# Label (clipped visually by segment width)
		var pct: float = (float(g.weight) / float(total_weight)) * 100.0
		var lbl: String = "%s\n%.0f%%" % [g.label, pct]
		draw_string(font, Vector2(x + 4.0, bar_h * 0.45), lbl,
				HORIZONTAL_ALIGNMENT_LEFT, seg_w - 6.0, font_size, Color.WHITE)

		x += seg_w

	# Outer border
	draw_rect(Rect2(0, 0, bar_w, bar_h), Color.BLACK, false, 2.0)

	# Needle
	var nx: float = clampf(needle_pos, 0.0, 1.0) * bar_w
	draw_line(Vector2(nx, -8.0), Vector2(nx, bar_h + 8.0), Color.WHITE, 3.0)
	# Needle triangle pointer at top
	draw_colored_polygon(PackedVector2Array([
		Vector2(nx, 0.0),
		Vector2(nx - 6.0, -12.0),
		Vector2(nx + 6.0, -12.0)
	]), Color.WHITE)
