# Main combat scene that connects UI elements to the combat manager
extends Node2D

@onready var combat_manager: CombatManager = $CombatManager
@onready var player_ui = $PlayerUI
@onready var enemy_ui = $EnemyUI
@onready var player_item_select = $PlayerItemSelect
@onready var roll_button = $RollButton
@onready var enemy_item_display = $EnemyItemDisplay

var _player_turn_active: bool = false

# Wire up all UI signals and start combat
func _ready() -> void:
	player_item_select.item_selected.connect(_on_player_item_selected)
	player_item_select.setup(GameData.player_items)

	# Wire roll button
	roll_button.roll_pressed.connect(_on_roll_pressed)

	# Wire combat manager turn signals
	combat_manager.player_turn_started.connect(_on_player_turn_started)
	combat_manager.player_turn_ended.connect(_on_player_turn_ended)

	# Start combat
	combat_manager.start_combat(GameData.enemy_order[GameData.enemies_fought], player_ui, enemy_ui)

	# Wire enemy item display after start_combat so enemy combatant exists
	combat_manager.enemy.selected_item_changed.connect(_on_enemy_item_changed)
	if combat_manager.enemy.selected_item:
		enemy_item_display.update_item(combat_manager.enemy.selected_item)

# Set the player's selected item and enable rolling
func _on_player_item_selected(item: ItemTemplate) -> void:
	combat_manager.player.selected_item = item
	if _player_turn_active:
		roll_button.rollable = true

# Lock controls and confirm the player's roll
func _on_roll_pressed() -> void:
	if _player_turn_active and combat_manager.player.selected_item:
		roll_button.rollable = false
		player_item_select.set_enabled(false)
		_player_turn_active = false
		combat_manager.confirm_roll()

# Enable item selection and roll button for the player's turn
func _on_player_turn_started() -> void:
	_player_turn_active = true
	player_item_select.set_enabled(true)
	if combat_manager.player.selected_item:
		roll_button.rollable = true

# Disable controls when the player's turn ends
func _on_player_turn_ended() -> void:
	_player_turn_active = false
	roll_button.rollable = false
	player_item_select.set_enabled(false)

# Update the enemy item display when their attack changes
func _on_enemy_item_changed(item: ItemTemplate) -> void:
	enemy_item_display.update_item(item)
