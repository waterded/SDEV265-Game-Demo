class_name Combatant
extends Node

signal hp_changed(new_hp: int, max_hp: int)
signal effect_changed(effect: Effect.Type, new_amount: int)
signal damage_taken(amount: int)
signal healed(amount: int)
signal died()
signal selected_item_changed(item: ItemTemplate)

var max_hp: int
var cur_hp: int
var cur_effects: Dictionary[Effect.Type,int]
var selected_item: ItemTemplate:
	set(value):
		selected_item = value
		selected_item_changed.emit(value)
var is_enemy: bool

func consume_effect(effect: Effect.Type, amount: int = -1) -> int:
	if not cur_effects.has(effect):
		return 0
	var current: int = cur_effects[effect]
	if amount < 0:
		cur_effects.erase(effect)
		effect_changed.emit(effect, 0)
		return current
	var subtracted: int = min(amount, current)
	cur_effects[effect] -= subtracted
	if cur_effects[effect] <= 0:
		cur_effects.erase(effect)
		effect_changed.emit(effect, 0)
	else:
		effect_changed.emit(effect, cur_effects[effect])
	return subtracted

func add_effect(effect: Effect.Type, amount: int) -> void:
	if cur_effects.has(effect):
		cur_effects[effect] += amount
	else:
		cur_effects[effect] = amount
	effect_changed.emit(effect, cur_effects[effect])

func heal(amount: int) -> void:
	var actual: int = max(min(amount, max_hp - cur_hp), 0)
	cur_hp += actual
	if actual > 0:
		healed.emit(actual)
		hp_changed.emit(cur_hp, max_hp)

func is_dead() -> bool:
	if cur_hp <= 0:
		died.emit()
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
	damage_taken.emit(amount)
	hp_changed.emit(cur_hp, max_hp)

func update_status() -> void:
	# POISON,
	if cur_effects.has(Effect.Type.POISON):
		apply_damage(cur_effects[Effect.Type.POISON])
		consume_effect(Effect.Type.POISON,1)
	
	# BLOCK,
	if cur_effects.has(Effect.Type.BLOCK):
		consume_effect(Effect.Type.BLOCK)
	
