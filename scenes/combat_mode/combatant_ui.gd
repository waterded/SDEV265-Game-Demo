extends VBoxContainer

## Reusable UI panel for one combatant. Displays (top to bottom):
## Sprite, EffectDisplay, HealthBar, ItemSelect placeholder, ProbabilityBar.
## Call setup() after adding to the tree to wire signals.

@onready var sprite: TextureRect = $Sprite
@onready var effect_display: EffectDisplay = $EffectDisplay
@onready var health_bar: CombatHealthBar = $HealthBar
@onready var item_select_slot: MarginContainer = $ItemSelectSlot
@onready var probability_bar: ProbabilityBar = $ProbabilityBar

var combatant: Combatant

func setup(p_combatant: Combatant, p_sprite_texture: Texture2D) -> void:
	combatant = p_combatant

	# Sprite
	sprite.texture = p_sprite_texture

	# Health bar
	health_bar.setup(combatant)

	# Effect display
	effect_display.setup(combatant)

	# Probability bar — reacts to selected item changes
	combatant.selected_item_changed.connect(_on_selected_item_changed)
	if combatant.selected_item:
		probability_bar.item = combatant.selected_item

func connect_roll_signals(manager: CombatManager) -> void:
	manager.roll_started.connect(_on_roll_started)
	manager.roll_position_changed.connect(_on_roll_position_changed)
	manager.roll_finished.connect(_on_roll_finished)

func _on_selected_item_changed(item: ItemTemplate) -> void:
	probability_bar.item = item

func _on_roll_started(rolling_combatant: Combatant, _item: ItemTemplate) -> void:
	if rolling_combatant == combatant:
		probability_bar.set_spinner(0.0)

func _on_roll_position_changed(value: float) -> void:
	if probability_bar.spinner_position >= 0.0:
		probability_bar.set_spinner(value)

func _on_roll_finished(rolling_combatant: Combatant, _index: int) -> void:
	if rolling_combatant == combatant:
		await get_tree().create_timer(0.5).timeout
		probability_bar.hide_spinner()
