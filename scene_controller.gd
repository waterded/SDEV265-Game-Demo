extends Node2D
 
@onready var scene_container = $SceneContainer  # Where scenes get added

func _ready() -> void:
    change_scene("res://scenes/start_menu/start_scene.tscn")

func change_scene(scene_path: String):
    # Remove old scene
    for child in scene_container.get_children():
        child.queue_free()
    
    # Add new scene
    print("loading ",scene_path)
    var new_scene = load(scene_path).instantiate()
    scene_container.add_child(new_scene)

func _unhandled_key_input(event: InputEvent) -> void:
    if event.is_action_pressed("debug_hammer"):
        GameData.player_items[2]=load("res://Combat System/Items/Player Items/debug_hammer.tres")