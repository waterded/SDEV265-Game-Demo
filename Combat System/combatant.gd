class_name Combatant
extends Node

var max_hp: int
var cur_hp: int
var cur_effects: Dictionary[Effect.Type,int]

# --- Enemy attack queue ---
var attack_queue: Array = []   # Array[ItemTemplate]
var attack_index: int = 0

func build_attack_queue(template: EnemyTemplate, rounds: int = 20) -> void:
	attack_queue.clear()
	attack_index = 0
	if template.Combos.is_empty():
		return
	var combo_i: int = 0
	var added: int = 0
	while added < rounds:
		var combo: Array = template.Combos[combo_i % template.Combos.size()]
		for item in combo:
			attack_queue.append(item)
			added += 1
			if added >= rounds:
				break
		combo_i += 1

func get_current_attack() -> ItemTemplate:
	if attack_queue.is_empty():
		return null
	return attack_queue[attack_index]

func advance_attack_queue() -> void:
	attack_index = (attack_index + 1) % attack_queue.size()

func consume_effect(effect: Effect.Type, amount: int = -1) -> int:
	if not cur_effects.has(effect):
		return 0
	var current: int = cur_effects[effect]
	if amount < 0:
		cur_effects.erase(effect)
		return current
	var subtracted: int = min(amount, current)
	cur_effects[effect] -= subtracted
	if cur_effects[effect] <= 0:
		cur_effects.erase(effect)
	return subtracted

func add_effect(effect: Effect.Type, amount: int) -> void:
	if cur_effects.has(effect):
		# Effect already exists, stack the new amount on top
		cur_effects[effect] += amount
	else:
		# Effect not present, add it as a new entry
		cur_effects[effect] = amount

func heal(amount: int) -> void:
	# Clamp heal to remaining capacity, and prevent negative heal if cur_hp > max_hp
	var healed: int = max(min(amount, max_hp-cur_hp),0)
	cur_hp += healed

func is_dead() -> bool:
	if cur_hp <= 0:
		#play death animation
		return true
	return false

func apply_damage(amount: int) -> void:
	if amount <= 0:
		return

	# Negate: cancel incoming damage and decrement the negate counter
	if consume_effect(Effect.Type.NEGATE, 1) > 0:
		return

	# Block/Armor: absorb damage as layers before HP
	amount -= consume_effect(Effect.Type.BLOCK, amount)
	if amount <= 0:
		return
	amount -= consume_effect(Effect.Type.ARMOR, amount)
	if amount <= 0:
		return
	# Apply remaining damage to HP
	cur_hp -= amount
