extends Node2D

@export var enemy: EnemyTemplate

@onready var combat_manager: CombatManager = $CombatManager
@onready var player_ui = $UILayer/CombatLayout/PlayerSection/PlayerUI
@onready var enemy_ui = $UILayer/CombatLayout/EnemySection/EnemyUI
@onready var player_item_select = $UILayer/CombatLayout/PlayerSection/PlayerItemSelect
@onready var roll_button = $UILayer/CombatLayout/PlayerSection/RollButton
@onready var enemy_item_display = $UILayer/CombatLayout/EnemySection/EnemyItemDisplay

var _player_turn_active: bool = false

func _ready() -> void:
	# Wire item selection
	player_item_select.item_selected.connect(_on_player_item_selected)
	player_item_select.setup(GameData.player_items)

	# Wire roll button
	roll_button.roll_pressed.connect(_on_roll_pressed)

	# Wire combat manager turn signals
	combat_manager.player_turn_started.connect(_on_player_turn_started)
	combat_manager.player_turn_ended.connect(_on_player_turn_ended)

	# Start combat
	combat_manager.start_combat(enemy, player_ui, enemy_ui)

	# Wire enemy item display after start_combat so enemy combatant exists
	combat_manager.enemy.selected_item_changed.connect(_on_enemy_item_changed)
	if combat_manager.enemy.selected_item:
		enemy_item_display.update_item(combat_manager.enemy.selected_item)

func _on_player_item_selected(item: ItemTemplate) -> void:
	combat_manager.player.selected_item = item
	if _player_turn_active:
		roll_button.rollable = true

func _on_roll_pressed() -> void:
	if _player_turn_active and combat_manager.player.selected_item:
		roll_button.rollable = false
		player_item_select.set_enabled(false)
		_player_turn_active = false
		combat_manager.confirm_roll()

func _on_player_turn_started() -> void:
	_player_turn_active = true
	player_item_select.set_enabled(true)
	if combat_manager.player.selected_item:
		roll_button.rollable = true

func _on_player_turn_ended() -> void:
	_player_turn_active = false
	roll_button.rollable = false
	player_item_select.set_enabled(false)

func _on_enemy_item_changed(item: ItemTemplate) -> void:
	enemy_item_display.update_item(item)
