# Data template defining an enemy's stats, sprite, and attack combos
class_name EnemyTemplate
extends Resource
@export var enemy_name: String = "Default Enemy"
@export var sprite: Texture2D
@export var base_hp: int = 50
@export var combos: Array[Array] = []
