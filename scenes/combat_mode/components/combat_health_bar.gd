@tool
class_name CombatHealthBar
extends Control

var _max_hp: int = 100
var _cur_hp: int = 100
var _display_hp: float = 100.0  # For tween animation
var _tween: Tween

const BAR_HEIGHT: float = 24.0
const BAR_RADIUS: float = 6.0
const BG_COLOR := Color(0.2, 0.2, 0.2)
const FILL_COLOR := Color(0.2, 0.8, 0.3)
const DAMAGE_COLOR := Color(0.8, 0.2, 0.2)
const LOW_HP_COLOR := Color(0.9, 0.3, 0.1)
const BORDER_COLOR := Color(0.7, 0.7, 0.7, 0.6)

func setup(combatant: Combatant) -> void:
	if Engine.is_editor_hint():
		return
	_max_hp = combatant.max_hp
	_cur_hp = combatant.cur_hp
	_display_hp = float(_cur_hp)
	combatant.hp_changed.connect(_on_hp_changed)
	queue_redraw()

func _on_hp_changed(new_hp: int, max_hp: int) -> void:
	if Engine.is_editor_hint():
		return
	_max_hp = max_hp
	_cur_hp = new_hp
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_method(_set_display_hp, _display_hp, float(_cur_hp), 0.4).set_ease(Tween.EASE_OUT)

func _set_display_hp(value: float) -> void:
	_display_hp = value
	queue_redraw()

func _draw() -> void:
	var bar_rect := Rect2(Vector2.ZERO, Vector2(size.x, BAR_HEIGHT))

	# Background
	_draw_rounded_rect(bar_rect, BG_COLOR)

	# HP fill
	if _max_hp > 0:
		var ratio: float = clampf(_display_hp / float(_max_hp), 0.0, 1.0)
		var fill_rect := Rect2(Vector2.ZERO, Vector2(size.x * ratio, BAR_HEIGHT))
		var color: Color = FILL_COLOR if ratio > 0.25 else LOW_HP_COLOR
		_draw_rounded_rect(fill_rect, color)

	# Border
	_draw_rounded_rect_outline(bar_rect, BORDER_COLOR)

	# HP text
	var hp_text: String = "%d / %d" % [maxi(int(_display_hp), 0), _max_hp]
	var font := ThemeDB.fallback_font
	var font_size: int = 14
	var text_size: Vector2 = font.get_string_size(hp_text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
	var text_pos := Vector2((size.x - text_size.x) * 0.5, (BAR_HEIGHT + text_size.y) * 0.5 - 2)
	draw_string(font, text_pos, hp_text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color.WHITE)

func _draw_rounded_rect(rect: Rect2, color: Color) -> void:
	if rect.size.x <= 0 or rect.size.y <= 0:
		return
	var r: float = minf(BAR_RADIUS, minf(rect.size.x * 0.5, rect.size.y * 0.5))
	var points := _get_rounded_rect_points(rect, r)
	draw_colored_polygon(points, color)

func _draw_rounded_rect_outline(rect: Rect2, color: Color) -> void:
	var r: float = minf(BAR_RADIUS, minf(rect.size.x * 0.5, rect.size.y * 0.5))
	var points := _get_rounded_rect_points(rect, r)
	points.append(points[0])
	draw_polyline(points, color, 2.0)

func _get_rounded_rect_points(rect: Rect2, radius: float) -> PackedVector2Array:
	var points := PackedVector2Array()
	var corners := [
		[Vector2(rect.position.x + radius, rect.position.y + radius), PI, PI * 1.5],
		[Vector2(rect.end.x - radius, rect.position.y + radius), PI * 1.5, PI * 2.0],
		[Vector2(rect.end.x - radius, rect.end.y - radius), 0, PI * 0.5],
		[Vector2(rect.position.x + radius, rect.end.y - radius), PI * 0.5, PI],
	]
	var segments: int = 8
	for corner in corners:
		var center: Vector2 = corner[0]
		var angle_start: float = corner[1]
		var angle_end: float = corner[2]
		for j in range(segments + 1):
			var angle: float = angle_start + (angle_end - angle_start) * (float(j) / float(segments))
			points.append(center + Vector2(cos(angle), sin(angle)) * radius)
	return points

func _get_minimum_size() -> Vector2:
	return Vector2(100, BAR_HEIGHT)
