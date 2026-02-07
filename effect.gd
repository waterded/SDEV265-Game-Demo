enum {
	DAMAGE, #Damage Target X amount
	ARMOR, #Takes X incoming damage before HP. Persists between turns
	NEGATE_DAMAGE, # negate X (or all if value == -1) damage
	POISON,
	STUN,
	SELF_LUCK, # shift weight toward better effects
	TARGET_LUCK, # shift enemy weight toward worse effects
	ROLL_AGAIN,
	MULTIPLY_NEXT,
	HEAL,
	NOTHING, # whiff / mis
}