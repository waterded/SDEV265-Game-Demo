class_name CombatManager
extends Node

signal roll_started(combatant: Combatant, item: ItemTemplate)
signal roll_position_changed(value: float)
signal roll_finished(combatant: Combatant, index: int)

var player: Combatant
var enemy: Combatant
var effect_resolver: EffectResolver
var attack_que: AttackQue

func start_combat(enemy_template: EnemyTemplate, player_ui, enemy_ui) -> void:
	effect_resolver = EffectResolver.new()
	attack_que = AttackQue.new()

	# Build player combatant from GameData
	player = Combatant.new()
	player.max_hp = GameData.player_max_health
	player.cur_hp = GameData.player_health
	player.is_enemy = false
	add_child(player)

	# Build enemy combatant from template
	enemy = Combatant.new()
	enemy.max_hp = enemy_template.base_hp
	enemy.cur_hp = enemy_template.base_hp
	enemy.is_enemy = true
	add_child(enemy)

	# Wire up UI panels
	var player_texture: Texture2D = load("res://assets/icon.svg")
	player_ui.setup(player, player_texture)
	player_ui.connect_roll_signals(self)
	enemy_ui.setup(enemy, enemy_template.sprite)
	enemy_ui.connect_roll_signals(self)

	enemy.selected_item = attack_que.build_que(enemy_template.combos)
	run_combat()

func run_combat()-> void:
	var in_combat: bool = true

	while in_combat:
		if player.cur_effects[Effect.Type.STUN]>0:
			player.consume_effect(Effect.Type.STUN,1)
		else:
			#player choose item
			#player press roll
			await _do_roll(player.selected_item, player, enemy)
			if _check_death():
				return
		
		if enemy.cur_effects[Effect.Type.STUN]>0:
			enemy.consume_effect(Effect.Type.STUN,1)
		else:
			await _do_roll(enemy.selected_item, enemy, player)
			if _check_death():
				return

		player.update_status()
		enemy.update_status()
		if _check_death():
				return

		enemy.selected_item = attack_que.get_next()

func _check_death() -> bool:
	return player.is_dead() or enemy.is_dead()

func _roll_curve(x: float, t: float) -> float:
	var inner: float = (asin(2.0 * t - 1.0) + 9.0 * PI) * (1.0 - pow(1.0 - x, 3.5)) - 9.0 * PI
	return 0.5 + 0.5 * sin(inner)

func _run_roll_animation(target: float, duration: float) -> void:
	var elapsed: float = 0.0
	while elapsed < duration:
		await get_tree().process_frame
		elapsed += get_process_delta_time()
		var x: float = minf(elapsed / duration, 1.0)
		var value: float = _roll_curve(x, target)
		roll_position_changed.emit(value)

func _run_luck_animation(from: float, to: float, duration: float) -> void:
	var elapsed: float = 0.0
	while elapsed < duration:
		await get_tree().process_frame
		elapsed += get_process_delta_time()
		var x: float = minf(elapsed / duration, 1.0)
		var value: float = lerp(from, to, x)
		roll_position_changed.emit(value)

func _get_roll_index(item: ItemTemplate, attacker: Combatant, time: float) -> int:
	# Sum weights
	var total_weight: int = 0
	for group in item.effect_groups:
		total_weight += group.weight

	# Roll as float in weight-space
	var roll: float = randf_range(0.0, float(total_weight))
	await _run_roll_animation(roll / float(total_weight), time)

	# Apply LUCK (full value shifts roll, converges toward 0 by 1)
	var pre_luck_pos: float = roll / float(total_weight)
	var luck: int = attacker.cur_effects.get(Effect.Type.LUCK, 0)
	roll = clamp(roll + float(luck), 0.0, float(total_weight))
	if luck > 0:
		attacker.consume_effect(Effect.Type.LUCK, 1)
		await _run_luck_animation(pre_luck_pos, roll / float(total_weight), time * 0.1)
	elif luck < 0:
		attacker.add_effect(Effect.Type.LUCK, 1)
		await _run_luck_animation(pre_luck_pos, roll / float(total_weight), time * 0.1)

	# Find index via cumulative walk (defaults to last group on edge)
	var index: int = item.effect_groups.size() - 1
	var cumulative: int = 0
	for i in range(item.effect_groups.size()):
		cumulative += item.effect_groups[i].weight
		if roll < float(cumulative):
			index = i
			break

	return index

func _do_roll(item: ItemTemplate, attacker: Combatant, target: Combatant) -> void:
	var index: int
	var rolling: bool = true
	var roll_time: float = 5

	while rolling:
		roll_started.emit(attacker, item)
		index = await _get_roll_index(item, attacker, roll_time)
		roll_finished.emit(attacker, index)

		#resolve effects
		var result = item.effect_groups[index].effects

		for effect in result:
			effect_resolver.apply_effect(effect, result[effect], attacker, target)

		#check for death
		if _check_death():
			return

		# Consume 1 ROLL_AGAIN charge; keep rolling only if one was available
		rolling = attacker.consume_effect(Effect.Type.ROLL_AGAIN, 1) > 0
		roll_time *= .8
