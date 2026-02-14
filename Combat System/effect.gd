#Autoload Singleton
extends Node
enum Type {
	DAMAGE,
	ARMOR,
	NEGATE, # negate  damage X times
	BLOCK,
	POISON,
	STUN,
	CURSE, # shift enemy weight toward worse effects
	LUCK,
	ROLL_AGAIN, # no probability cost
	MULTIPLY_NEXT,
	HEAL,
	NOTHING, # whiff / mis
}