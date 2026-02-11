class_name ItemTemplate
extends Resource
@export var display_name: String = "Default Item"
@export var icon: Texture2D
@export var rarity: int = 0 # 0 = common ... 4 = legendary, -1 = enemy-only
@export var is_consumable: bool = false
@export var effect_groups: Array[EffectGroup] = []
