extends Node2D

@export var enemy: EnemyTemplate

func _ready() -> void:
	var player_ui = $UILayer/CombatLayout/PlayerUI
	var enemy_ui = $UILayer/CombatLayout/EnemyUI
	$CombatManager.start_combat(enemy, player_ui, enemy_ui)