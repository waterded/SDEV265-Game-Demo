extends Node2D

const MIMIC_TEMPLATE  = preload("res://Combat System/Enemies/mimic.tres")
const RAPIER_TEMPLATE = preload("res://Combat System/Items/Player Items/rapier.tres")

# --- Combatants & logic ---
var player: Combatant
var enemy: Combatant
var combat_manager: CombatManager

# --- UI nodes (built in code) ---
var enemy_name_label:   Label
var enemy_sprite_rect:  TextureRect
var enemy_hp_label:     Label
var enemy_effects_label: Label
var enemy_next_label:   Label
var player_hp_label:    Label
var player_effects_label: Label
var prob_bar_label:     Label
var prob_bar:           ProbabilityBar
var item_container:     HBoxContainer
var turn_label:         Label
var message_label:      Label

# --- State ---
var player_items: Array = []  # Array[ItemTemplate]
signal _item_chosen(item: ItemTemplate)

# ──────────────────────────────────────────────────────────────────────────────
func _ready() -> void:
	_setup_combatants()
	_setup_combat_manager()
	_build_ui()
	_update_all_labels()
	# Fire-and-forget: runs as a coroutine; _ready() returns immediately
	_run_combat()

# ──────────────────────────────────────────────────────────────────────────────
#  SETUP
# ──────────────────────────────────────────────────────────────────────────────
func _setup_combatants() -> void:
	player = Combatant.new()
	player.max_hp = GameData.player_max_health
	player.cur_hp  = GameData.player_health
	add_child(player)

	enemy = Combatant.new()
	enemy.max_hp = MIMIC_TEMPLATE.base_hp
	enemy.cur_hp  = MIMIC_TEMPLATE.base_hp
	enemy.build_attack_queue(MIMIC_TEMPLATE)
	add_child(enemy)

	# Build player item list (fallback to rapier when GameData has nothing)
	if GameData.player_items != null and not GameData.player_items.is_empty():
		player_items = GameData.player_items
	else:
		player_items = [RAPIER_TEMPLATE]

func _setup_combat_manager() -> void:
	combat_manager = CombatManager.new()
	combat_manager.player          = player
	combat_manager.enemy           = enemy
	combat_manager.effect_resolver = EffectResolver.new()
	add_child(combat_manager)
	combat_manager.needle_moved.connect(_on_needle_moved)
	combat_manager.roll_started.connect(_on_roll_started)

# ──────────────────────────────────────────────────────────────────────────────
#  UI CONSTRUCTION
# ──────────────────────────────────────────────────────────────────────────────
func _build_ui() -> void:
	var canvas = CanvasLayer.new()
	add_child(canvas)

	var root = Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	canvas.add_child(root)

	# ── Enemy panel (top-left) ──────────────────────────────────────────────
	var enemy_panel = VBoxContainer.new()
	enemy_panel.position = Vector2(30, 20)
	root.add_child(enemy_panel)

	enemy_name_label = Label.new()
	enemy_name_label.add_theme_font_size_override("font_size", 22)
	enemy_panel.add_child(enemy_name_label)

	enemy_sprite_rect = TextureRect.new()
	enemy_sprite_rect.texture = MIMIC_TEMPLATE.sprite
	enemy_sprite_rect.custom_minimum_size = Vector2(120, 120)
	enemy_sprite_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	enemy_panel.add_child(enemy_sprite_rect)

	enemy_hp_label = Label.new()
	enemy_panel.add_child(enemy_hp_label)

	enemy_effects_label = Label.new()
	enemy_effects_label.add_theme_color_override("font_color", Color(1.0, 0.7, 0.3))
	enemy_panel.add_child(enemy_effects_label)

	enemy_next_label = Label.new()
	enemy_next_label.add_theme_color_override("font_color", Color(0.8, 0.8, 1.0))
	enemy_panel.add_child(enemy_next_label)

	# ── Turn / message strip (center-top) ──────────────────────────────────
	turn_label = Label.new()
	turn_label.position = Vector2(450, 20)
	turn_label.add_theme_font_size_override("font_size", 26)
	turn_label.add_theme_color_override("font_color", Color.YELLOW)
	root.add_child(turn_label)

	message_label = Label.new()
	message_label.position = Vector2(450, 60)
	message_label.size = Vector2(650, 80)
	message_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	root.add_child(message_label)

	# ── Probability bar (center) ────────────────────────────────────────────
	prob_bar_label = Label.new()
	prob_bar_label.position = Vector2(30, 230)
	prob_bar_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
	root.add_child(prob_bar_label)

	prob_bar = ProbabilityBar.new()
	prob_bar.position = Vector2(30, 255)
	prob_bar.size     = Vector2(1090, 55)
	root.add_child(prob_bar)

	# ── Player panel (bottom-left) ─────────────────────────────────────────
	player_hp_label = Label.new()
	player_hp_label.position = Vector2(30, 460)
	player_hp_label.add_theme_font_size_override("font_size", 20)
	root.add_child(player_hp_label)

	player_effects_label = Label.new()
	player_effects_label.position = Vector2(30, 490)
	player_effects_label.add_theme_color_override("font_color", Color(1.0, 0.7, 0.3))
	root.add_child(player_effects_label)

	# ── Item buttons ────────────────────────────────────────────────────────
	var items_header = Label.new()
	items_header.position = Vector2(30, 525)
	items_header.text = "Choose an item:"
	root.add_child(items_header)

	item_container = HBoxContainer.new()
	item_container.position = Vector2(30, 550)
	item_container.add_theme_constant_override("separation", 12)
	root.add_child(item_container)

	for item in player_items:
		var btn = Button.new()
		btn.text = item.display_name
		btn.custom_minimum_size = Vector2(160, 60)
		btn.pressed.connect(_on_item_pressed.bind(item))
		btn.mouse_entered.connect(_on_item_hovered.bind(item))
		item_container.add_child(btn)

# ──────────────────────────────────────────────────────────────────────────────
#  MAIN COMBAT LOOP
# ──────────────────────────────────────────────────────────────────────────────
func _run_combat() -> void:
	while true:
		# ── PLAYER TURN ──────────────────────────────────────────────────────
		turn_label.text = "Your Turn"

		if player.consume_effect(Effect.Type.STUN, 1) > 0:
			message_label.text = "You are stunned — turn skipped!"
			await get_tree().create_timer(1.5).timeout
		else:
			# Preview the enemy's upcoming attack on the bar
			var next_atk = enemy.get_current_attack()
			if next_atk:
				prob_bar.set_item(next_atk)
				prob_bar_label.text = "Enemy's next attack: " + next_atk.display_name
				enemy_next_label.text = "Next: " + next_atk.display_name

			_set_buttons_enabled(true)
			var chosen: ItemTemplate = await _item_chosen
			_set_buttons_enabled(false)

			var p_hp_before: int = player.cur_hp
			var e_hp_before: int = enemy.cur_hp
			message_label.text = "Rolling %s…" % chosen.display_name
			await combat_manager._do_roll(chosen, player, enemy)
			_update_all_labels()
			_show_roll_result(p_hp_before, e_hp_before)

			if combat_manager._check_death():
				_end_combat()
				return

		_tick_end_of_turn()
		_update_all_labels()
		if combat_manager._check_death():
			_end_combat()
			return

		# ── ENEMY TURN ───────────────────────────────────────────────────────
		turn_label.text = "Enemy's Turn"

		if enemy.consume_effect(Effect.Type.STUN, 1) > 0:
			message_label.text = "Enemy is stunned — their turn is skipped!"
			enemy.advance_attack_queue()
			await get_tree().create_timer(1.5).timeout
		else:
			var atk: ItemTemplate = enemy.get_current_attack()
			if atk:
				prob_bar.set_item(atk)
				prob_bar_label.text = "Enemy attacks with: " + atk.display_name
				message_label.text = "Enemy uses %s!" % atk.display_name
				await get_tree().create_timer(0.6).timeout

				var p_hp_before: int = player.cur_hp
				var e_hp_before: int = enemy.cur_hp
				await combat_manager._do_roll(atk, enemy, player)
				enemy.advance_attack_queue()
				_update_all_labels()
				_show_roll_result(p_hp_before, e_hp_before)

				if combat_manager._check_death():
					_end_combat()
					return

		_tick_end_of_turn()
		_update_all_labels()
		if combat_manager._check_death():
			_end_combat()
			return

# ──────────────────────────────────────────────────────────────────────────────
#  HELPERS
# ──────────────────────────────────────────────────────────────────────────────
func _tick_end_of_turn() -> void:
	# Poison deals damage then decrements
	for combatant in [player, enemy]:
		var poison: int = combatant.cur_effects.get(Effect.Type.POISON, 0)
		if poison > 0:
			combatant.apply_damage(poison)
			combatant.consume_effect(Effect.Type.POISON, 1)

func _show_roll_result(p_before: int, e_before: int) -> void:
	var msgs: Array = []
	var dmg_to_enemy  = e_before - enemy.cur_hp
	var dmg_to_player = p_before - player.cur_hp
	if dmg_to_enemy  > 0: msgs.append("Dealt %d damage to enemy."  % dmg_to_enemy)
	if dmg_to_player > 0: msgs.append("Took %d damage."            % dmg_to_player)
	if dmg_to_enemy  < 0: msgs.append("Enemy healed %d HP."        % -dmg_to_enemy)
	if dmg_to_player < 0: msgs.append("You healed %d HP."          % -dmg_to_player)
	if msgs.is_empty():    msgs.append("No damage dealt.")
	message_label.text = " | ".join(msgs)

func _update_all_labels() -> void:
	player_hp_label.text = "Player HP: %d / %d" % [player.cur_hp, player.max_hp]
	enemy_hp_label.text  = "%s HP: %d / %d" % [MIMIC_TEMPLATE.enemy_name, enemy.cur_hp, enemy.max_hp]
	player_effects_label.text  = _effects_string(player)
	enemy_effects_label.text   = _effects_string(enemy)
	enemy_name_label.text      = MIMIC_TEMPLATE.enemy_name

func _effects_string(c: Combatant) -> String:
	if c.cur_effects.is_empty():
		return ""
	var parts: Array = []
	for e in c.cur_effects:
		parts.append("%s:%d" % [Effect.Type.keys()[e], c.cur_effects[e]])
	return " | ".join(parts)

func _set_buttons_enabled(enabled: bool) -> void:
	for btn in item_container.get_children():
		btn.disabled = not enabled

func _end_combat() -> void:
	_set_buttons_enabled(false)
	if player.is_dead():
		message_label.text = "You have been defeated…"
		GameData.player_health = 0
		GameData.player_won    = false
	else:
		message_label.text = "Victory! Enemy defeated!"
		GameData.player_health = player.cur_hp
		GameData.enemies_fought += 1
		GameData.player_won = true
	await get_tree().create_timer(2.5).timeout
	SceneRelay.change_scene(SceneRelay.GAME_OVER)

# ──────────────────────────────────────────────────────────────────────────────
#  SIGNAL HANDLERS
# ──────────────────────────────────────────────────────────────────────────────
func _on_item_pressed(item: ItemTemplate) -> void:
	_item_chosen.emit(item)

func _on_item_hovered(item: ItemTemplate) -> void:
	prob_bar.set_item(item)
	prob_bar_label.text = item.display_name

func _on_needle_moved(pos: float) -> void:
	prob_bar.set_needle(pos)

func _on_roll_started(item: ItemTemplate) -> void:
	prob_bar.set_item(item)
	prob_bar_label.text = item.display_name
