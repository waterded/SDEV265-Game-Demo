class_name CombatManager
extends Node

signal needle_moved(position: float)
signal roll_started(item: ItemTemplate)

var player: Combatant
var enemy: Combatant
var effect_resolver: EffectResolver

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
		needle_moved.emit(_roll_curve(x, target))

func _run_luck_animation(from: float, to: float, duration: float) -> void:
	var elapsed: float = 0.0
	while elapsed < duration:
		await get_tree().process_frame
		elapsed += get_process_delta_time()
		var x: float = minf(elapsed / duration, 1.0)
		needle_moved.emit(lerp(from, to, x))

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
	roll_started.emit(item)
	var index: int
	var rolling: bool = true
	var roll_time: float = 2.0

	while rolling:
		index = await _get_roll_index(item, attacker, roll_time)

		# resolve effects
		var result = item.effect_groups[index].effects

		for effect in result:
			effect_resolver.apply_effect(effect, result[effect], attacker, target)

		# check for death
		if _check_death():
			return

		# Consume 1 ROLL_AGAIN charge; keep rolling only if one was available
		rolling = attacker.consume_effect(Effect.Type.ROLL_AGAIN, 1) > 0
		roll_time *= .8
