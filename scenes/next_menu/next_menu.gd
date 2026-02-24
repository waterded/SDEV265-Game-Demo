extends Node2D

@onready var enemy_text : RichTextLabel = $GameTitle

func _ready() -> void:
	enemy_text.text = GameData.enemy_order[GameData.enemies_fought-1].enemy_name +"\nDefeated"

