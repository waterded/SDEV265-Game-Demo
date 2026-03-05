# Displays the defeated enemy name between combat rounds
extends Node2D

@onready var enemy_text : RichTextLabel = $GameTitle

# Show the name of the last defeated enemy
func _ready() -> void:
	enemy_text.text = GameData.enemy_order[GameData.enemies_fought-1].enemy_name +"\nDefeated"
