#Autoload Singleton
extends Node
enum Type {
	DAMAGE,
	ARMOR,
	NEGATE, # negate  damage X times
	BLOCK,
	POISON,
	STUN,
	SELF_LUCK, # shift weight toward better effects
	TARGET_LUCK, # shift enemy weight toward worse effects
	ROLL_AGAIN, # no probability cost
	MULTIPLY_NEXT,
	HEAL,
	NOTHING, # whiff / mis
}