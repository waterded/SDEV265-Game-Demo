class_name EffectResolver
extends RefCounted

func apply_effect(effect: Effect.Type, amount: int, attacker: Combatant, target: Combatant) ->void:
    amount = amount*attacker.cur_effects.get(Effect.Type.MULTIPLY_NEXT,1)
    attacker.cur_effects.erase(Effect.Type.MULTIPLY_NEXT)

    match effect:
        Effect.Type.DAMAGE:
            target.apply_damage(amount)
            pass
        #ARMOR,
	    #NEGATE_DAMAGE, # negate X (or all if value == -1) damage
	    #POISON,
	    #STUN,
	    #SELF_LUCK, # shift weight toward better effects
	    #TARGET_LUCK, # shift enemy weight toward worse effects
	    #ROLL_AGAIN, # no probability cost
	    #MULTIPLY_NEXT,
	    #HEAL,
	    #NOTHING, # whiff / mis
    pass