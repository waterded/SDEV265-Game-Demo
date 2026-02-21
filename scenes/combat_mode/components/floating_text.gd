class_name FloatingText
extends Control

## Spawns animated floating text labels on the combatant UI.
## Call setup() to connect to a combatant's signals.

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

const STACK_OFFSET := 24.0  # vertical spacing between simultaneous texts

var _prev_effects: Dictionary = {}
var _sprite_node: TextureRect
var _stack_count: int = 0
var _stack_reset_timer: SceneTreeTimer

func setup(combatant: Combatant, sprite: TextureRect) -> void:
	_sprite_node = sprite
	combatant.damage_taken.connect(_on_damage_taken)
	combatant.healed.connect(_on_healed)
	combatant.effect_changed.connect(_on_effect_changed)
	# Snapshot current effects
	for effect in combatant.cur_effects:
		_prev_effects[effect] = combatant.cur_effects[effect]

func _on_damage_taken(amount: int) -> void:
	_spawn_text("-%d HP" % amount, Color(0.9, 0.2, 0.2))

func _on_healed(amount: int) -> void:
	_spawn_text("+%d HP" % amount, Color(0.2, 0.9, 0.4))

func _on_effect_changed(effect: Effect.Type, new_amount: int) -> void:
	var prev: int = _prev_effects.get(effect, 0)
	var delta: int = new_amount - prev
	_prev_effects[effect] = new_amount
	if new_amount == 0:
		_prev_effects.erase(effect)

	if delta == 0:
		return

	var effect_name: String = EFFECT_NAMES.get(effect, "???")
	var base_color: Color = _get_effect_color(effect)

	if delta > 0:
		_spawn_text("+%d %s" % [delta, effect_name], base_color)
	else:
		# Dimmer color for loss
		_spawn_text("%d %s" % [delta, effect_name], base_color.darkened(0.3))

func _spawn_text(text: String, color: Color) -> void:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 20)
	label.add_theme_color_override("font_color", color)
	# Outline for readability
	label.add_theme_constant_override("outline_size", 3)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	# Prevent VBoxContainer from laying out this label
	label.top_level = true

	# Add to the CombatantUI parent so coordinates are in its space
	get_parent().add_child(label)

	# Stack offset so simultaneous texts don't overlap
	var y_offset := _stack_count * STACK_OFFSET
	_stack_count += 1
	if _stack_reset_timer:
		_stack_reset_timer.timeout.disconnect(_reset_stack)
	_stack_reset_timer = get_tree().create_timer(0.3)
	_stack_reset_timer.timeout.connect(_reset_stack)

	# Position near bottom of Sprite in global coords, with random x jitter
	var sprite_global := _sprite_node.global_position
	var sprite_center_x := sprite_global.x + _sprite_node.size.x * 0.5
	var sprite_bottom := sprite_global.y + _sprite_node.size.y
	var jitter_x := randf_range(-20.0, 20.0)
	label.global_position = Vector2(sprite_center_x + jitter_x - label.size.x * 0.5, sprite_bottom - 20.0 - y_offset)

	# Animate: float up and fade out
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "global_position:y", label.global_position.y - 60.0, 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(label, "modulate:a", 0.0, 0.7).set_delay(0.3)
	tween.chain().tween_callback(label.queue_free)

func _reset_stack() -> void:
	_stack_count = 0

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
