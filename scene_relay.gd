#scene relay is a helper autoload that lets scenes communicate that a new scene should start without needing to know the path or reference the root node.

extends Node

#enums for scene change readability
enum {
	START_MENU,
	DIFFICULTY_SELECT,
	COMBAT,
	ITEM_SELECTION,
	GAME_OVER
}

#stores the path for each scene enum
var scene_path_dict = {
	START_MENU: "res://scenes/start_menu/start_scene.tscn",
	DIFFICULTY_SELECT: "res://scenes/difficulty_select/difficulty_select_scene.tscn",
	COMBAT: "",
	ITEM_SELECTION: "",
	GAME_OVER: ""
}

#calls the change to the main scene controller.
func change_scene(scene: int):
	#throws error if a bad enum is inserted.
	assert(scene in scene_path_dict, "Invalid scene enum value")
	get_node("/root/SceneController").change_scene(scene_path_dict[scene])
