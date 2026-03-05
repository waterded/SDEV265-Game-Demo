# Root scene manager that swaps scenes in and out of the container
extends Node2D

@onready var scene_container = $SceneContainer

# Load the start menu on launch
func _ready() -> void:
    change_scene("res://scenes/start_menu/start_scene.tscn")

# Remove the current scene and load a new one
func change_scene(scene_path: String):
    for child in scene_container.get_children():
        child.queue_free()
    print("loading ",scene_path)
    var new_scene = load(scene_path).instantiate()
    scene_container.add_child(new_scene)

# Swap in the debug hammer item when the hotkey is pressed
func _unhandled_key_input(event: InputEvent) -> void:
    if event.is_action_pressed("debug_hammer"):
        GameData.player_items[2]=load("res://Combat System/Items/Player Items/debug_hammer.tres")