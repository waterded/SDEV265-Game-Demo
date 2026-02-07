extends Node2D

@export var item: ItemTemplate
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(item.effect_groups[1].color,item.effect_groups[1].label)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
