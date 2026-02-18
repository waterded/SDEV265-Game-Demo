# Manages a rolling queue of enemy attacks built from random combo sequences.
# Ensures the queue always has upcoming attacks ready so the combat system
# can look ahead for telegraphing or UI purposes.
class_name AttackQue
extends Node

# The upcoming attacks the enemy will perform, in order.
var que: Array[ItemTemplate] = []
# The pool of valid combo sequences this enemy can draw from.
var combos: Array[Array]

# Initializes the queue with the enemy's combo pool and returns the first attack.
func build_que(enemy_combos: Array[Array]) -> ItemTemplate:
	# Filter out any empty combo arrays to prevent infinite loops in get_next()
	for combo in enemy_combos:
		if not combo.is_empty():
			combos.append(combo)

	assert(combos.size() > 0, "AttackQue: No valid combos provided. Each enemy needs at least one non-empty combo.")
	return get_next()

# Consumes the current attack and refills the queue with random combos
# until there are at least 2 attacks queued. Returns the next attack.
func get_next() -> ItemTemplate:
	que.pop_front()
	while que.size() < 2:
		que.append_array(combos[randi_range(0, combos.size() - 1)])
	return que[0]
