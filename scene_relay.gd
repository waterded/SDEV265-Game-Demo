#scene relay is a helper autoload that lets scenes communicate that a new scene should start without needing to know the path or reference the root node.

extends Node

# Load the button sound effect
var button_sound = preload("res://assets/Audio/floraphonic-metal-blade-slice-80-200898.mp3")
var audio_player: AudioStreamPlayer

func _ready():
	# Create an AudioStreamPlayer when SceneRelay initializes
	audio_player = AudioStreamPlayer.new()
	add_child(audio_player)

#enums for scene change readability
enum {
	START_MENU,
	DIFFICULTY_SELECT,
	COMBAT,
	ITEM_SELECTION,
	GAME_OVER,
	RESOURCE_EDITOR
}

#stores the path for each scene enum
var scene_path_dict = {
	START_MENU: "res://scenes/start_menu/start_scene.tscn",
	DIFFICULTY_SELECT: "res://scenes/difficulty_select/difficulty_select_scene.tscn",
	COMBAT: "res://scenes/combat_mode/combat_scene.tscn",
	ITEM_SELECTION: "",
	GAME_OVER: "res://scenes/game_over/game_over_scene.tscn",
	RESOURCE_EDITOR: "res://scenes/resource_editor/resource_editor.tscn"
}

#plays a UI sound effect that persists across scene changes
func play_ui_sound(sound: AudioStream):
	audio_player.stream = sound
	audio_player.play()

#plays the button click sound
func play_button_sound():
	play_ui_sound(button_sound)

#calls the change to the main scene controller.
func change_scene(scene: int):
	#throws error if a bad enum is inserted.
	assert(scene in scene_path_dict, "Invalid scene enum value")
	get_node("/root/SceneController").change_scene(scene_path_dict[scene])
