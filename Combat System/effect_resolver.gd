class_name EffectResolver
extends RefCounted

func apply_effect(effect: Effect.Type, amount: int, attacker: Combatant, target: Combatant) -> void:
	if effect == Effect.Type.NOTHING:
		return

	amount = amount * attacker.cur_effects.get(Effect.Type.MULTIPLY_NEXT, 1)
	attacker.cur_effects.erase(Effect.Type.MULTIPLY_NEXT)

	match effect:
		Effect.Type.DAMAGE:
			target.apply_damage(amount)
		Effect.Type.STUN:
			target.add_effect(Effect.Type.STUN, amount)
		Effect.Type.POISON:
			target.add_effect(Effect.Type.POISON, amount)
		Effect.Type.CURSE:
			target.add_effect(Effect.Type.LUCK, -amount)
		Effect.Type.HEAL:
			attacker.heal(amount)
		_:
			attacker.add_effect(effect, amount)