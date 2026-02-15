extends Node2D

func _ready() -> void:
	var canvas = CanvasLayer.new()
	add_child(canvas)

	var root = Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	canvas.add_child(root)

	# Background tint
	var bg = ColorRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.05, 0.05, 0.05, 0.88)
	root.add_child(bg)

	# Title
	var title = Label.new()
	title.position = Vector2(376, 160)
	title.size = Vector2(400, 80)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 56)
	if GameData.player_won:
		title.text = "Victory!"
		title.add_theme_color_override("font_color", Color.GOLD)
	else:
		title.text = "You Died"
		title.add_theme_color_override("font_color", Color.RED)
	root.add_child(title)

	# Stats
	var stats = Label.new()
	stats.position = Vector2(376, 260)
	stats.size = Vector2(400, 40)
	stats.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stats.add_theme_font_size_override("font_size", 22)
	stats.text = "Enemies defeated: %d" % GameData.enemies_fought
	root.add_child(stats)

	# Play Again button
	var play_btn = Button.new()
	play_btn.position = Vector2(426, 340)
	play_btn.size = Vector2(300, 55)
	play_btn.text = "Play Again"
	play_btn.add_theme_font_size_override("font_size", 20)
	play_btn.pressed.connect(_on_play_again)
	root.add_child(play_btn)

	# Main Menu button
	var menu_btn = Button.new()
	menu_btn.position = Vector2(426, 415)
	menu_btn.size = Vector2(300, 55)
	menu_btn.text = "Main Menu"
	menu_btn.add_theme_font_size_override("font_size", 20)
	menu_btn.pressed.connect(_on_main_menu)
	root.add_child(menu_btn)

func _on_play_again() -> void:
	SceneRelay.play_button_sound()
	GameData.reset()
	SceneRelay.change_scene(SceneRelay.DIFFICULTY_SELECT)

func _on_main_menu() -> void:
	SceneRelay.play_button_sound()
	GameData.reset()
	SceneRelay.change_scene(SceneRelay.START_MENU)
