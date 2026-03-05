# A weighted group of effects used as one outcome in an item roll
class_name EffectGroup
extends Resource

@export var label: String = "Default"
@export var weight: int = 1
@export var color: Color = Color.WHITE
@export var effects: Dictionary[Effect.Type,int] = {}