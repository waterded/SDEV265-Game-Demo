#Autoload for managing persistent data.

extends Node

var difficulty : int
var player_max_health : int:
	set(value):
		player_max_health = value
		player_health = min(player_max_health,player_health)

var player_health : int:
	set(value):
		if value>player_max_health:
			player_health=player_max_health
		else:
			player_health=value

var enemies_fought : int
var player_items

func reset() -> void:
	difficulty = 100
	player_max_health = 50
	player_health = 50
	enemies_fought = 0
	player_items = []