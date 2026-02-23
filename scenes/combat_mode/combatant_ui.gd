@tool
extends VBoxContainer

## Reusable UI panel for one combatant. Displays (top to bottom):
## Sprite, EffectDisplay, HealthBar, ProbabilityBar.
## Call setup() after adding to the tree to wire signals.

@onready var sprite: TextureRect = $Sprite
@onready var effect_display: EffectDisplay = $EffectDisplay
@onready var floating_text: FloatingText = $FloatingText
@onready var health_bar: CombatHealthBar = $HealthBar
@onready var probability_bar: ProbabilityBar = $ProbabilityBar

var combatant: Combatant

func setup(p_combatant: Combatant, p_sprite_texture: Texture2D) -> void:
	if Engine.is_editor_hint():
		return
	combatant = p_combatant

	# Sprite
	sprite.texture = p_sprite_texture
	if p_combatant.is_enemy:
		sprite.flip_h = true

	# Health bar
	health_bar.setup(combatant)

	# Effect display
	effect_display.setup(combatant)

	# Floating combat text
	floating_text.setup(combatant, sprite)

	# Probability bar — reacts to selected item changes
	combatant.selected_item_changed.connect(_on_selected_item_changed)
	if combatant.selected_item:
		probability_bar.item = combatant.selected_item

func connect_roll_signals(manager: CombatManager) -> void:
	if Engine.is_editor_hint():
		return
	manager.roll_started.connect(_on_roll_started)
	manager.roll_position_changed.connect(_on_roll_position_changed)
	manager.roll_finished.connect(_on_roll_finished)

func _on_selected_item_changed(item: ItemTemplate) -> void:
	if Engine.is_editor_hint():
		return
	probability_bar.item = item

func _on_roll_started(rolling_combatant: Combatant, _item: ItemTemplate) -> void:
	if Engine.is_editor_hint():
		return
	if rolling_combatant == combatant:
		probability_bar.set_spinner(0.0)

func _on_roll_position_changed(rolling_combatant: Combatant, value: float) -> void:
	if Engine.is_editor_hint():
		return
	if rolling_combatant == combatant:
		probability_bar.set_spinner(value)

func _on_roll_finished(rolling_combatant: Combatant, _index: int) -> void:
	if Engine.is_editor_hint():
		return
	if rolling_combatant == combatant:
		probability_bar.hide_spinner()
