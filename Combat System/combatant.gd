class_name Combatant
extends Node

var max_hp: int
var cur_hp: int
var cur_effects: Dictionary[Effect.Type,int]

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

func apply_damage(amount: int) -> void:
	# Negate: cancel incoming damage and decrement the negate counter
	if cur_effects.has(Effect.Type.NEGATE) and amount > 0:
		cur_effects[Effect.Type.NEGATE] -= 1
		if cur_effects[Effect.Type.NEGATE] <= 0:
			cur_effects.erase(Effect.Type.NEGATE)
		return

	# Block: absorbs damage as a layer before HP
	if cur_effects.has(Effect.Type.BLOCK) and amount > 0:
		if amount >= cur_effects[Effect.Type.BLOCK]:
			amount -= cur_effects[Effect.Type.BLOCK]
			cur_effects.erase(Effect.Type.BLOCK)
		else:
			cur_effects[Effect.Type.BLOCK] -= amount
			return

	# Armor: same as block, absorbs remaining damage before HP
	if cur_effects.has(Effect.Type.ARMOR) and amount > 0:
		if amount >= cur_effects[Effect.Type.ARMOR]:
			amount -= cur_effects[Effect.Type.ARMOR]
			cur_effects.erase(Effect.Type.ARMOR)
		else:
			cur_effects[Effect.Type.ARMOR] -= amount
			return

	# Apply remaining damage to HP
	cur_hp -= amount
