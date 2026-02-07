extends Node
enum Type {
	DAMAGE,
	ARMOR,
	NEGATE_DAMAGE, # negate X (or all if value == -1) damage
	POISON,
	STUN,
	SELF_LUCK, # shift weight toward better effects
	TARGET_LUCK, # shift enemy weight toward worse effects
	ROLL_AGAIN, # no probability cost
	MULTIPLY_NEXT,
	HEAL,
	NOTHING, # whiff / mis
}