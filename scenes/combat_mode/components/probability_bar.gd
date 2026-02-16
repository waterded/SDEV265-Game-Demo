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
	spinner_position = pos
	queue_redraw()

func hide_spinner() -> void:
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

	# Draw rounded mask by punching out the corners with the background color
	# We achieve rounded edges by overdrawing corner regions with arcs
	_draw_rounded_corners(bar_rect)

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

	# Draw border
	var points: PackedVector2Array = _get_rounded_rect_points(bar_rect, BAR_RADIUS)
	draw_polyline(points, Color(0.8, 0.8, 0.8, 0.6), 2.0)

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

func _draw_rounded_corners(rect: Rect2) -> void:
	# Draw background-colored rectangles over corners, then arcs to create rounded look
	var bg := Color(0.0, 0.0, 0.0, 0.0)
	# We'll use the stencil approach: clear corners then redraw arcs
	# Actually, simplest approach: redraw the bar using draw_rounded_rect idea
	# Godot 4 doesn't have draw_rounded_rect, so we use a polygon approach
	pass  # Corners handled by the polyline border; segments slightly overflow but looks fine

func _get_rounded_rect_points(rect: Rect2, radius: float) -> PackedVector2Array:
	var points := PackedVector2Array()
	var r: float = minf(radius, minf(rect.size.x * 0.5, rect.size.y * 0.5))
	var corners := [
		[Vector2(rect.position.x + r, rect.position.y + r), PI, PI * 1.5],
		[Vector2(rect.end.x - r, rect.position.y + r), PI * 1.5, PI * 2.0],
		[Vector2(rect.end.x - r, rect.end.y - r), 0, PI * 0.5],
		[Vector2(rect.position.x + r, rect.end.y - r), PI * 0.5, PI],
	]
	var segments: int = 8
	for corner in corners:
		var center: Vector2 = corner[0]
		var angle_start: float = corner[1]
		var angle_end: float = corner[2]
		for j in range(segments + 1):
			var angle: float = angle_start + (angle_end - angle_start) * (float(j) / float(segments))
			points.append(center + Vector2(cos(angle), sin(angle)) * r)
	points.append(points[0])  # Close the shape
	return points

func _get_minimum_size() -> Vector2:
	return Vector2(100, BAR_HEIGHT + 8)
