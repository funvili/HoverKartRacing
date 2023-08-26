extends Control

var mouse = false
var play_mouse = false

var normal_panel: Color
var selected_panel: Color
var normal_text: Color
var selected_text: Color

var selected_map
var map_data = [
['The Loop', 'Easy', 'Why not just race around in circles and see who can reach the end the fastest?'],
['Tight Turns', 'Medium', 'Sharp twist and turns that are sure to fling you off into oblivion :)'],
['Criss-Cross', 'Hard', 'Multiple tracks that are just better than others, dont get mixed up though!']
]

func _ready():
	normal_panel.r = 0.5
	normal_panel.g = 0.5
	normal_panel.b = 0.5
	
	selected_panel.r = 2550
	selected_panel.g = 2550
	selected_panel.b = 2550
	
	normal_text = selected_panel
	
	selected_text.r = 0
	selected_text.g = 0
	selected_text.b = 0

func _physics_process(delta):
	if mouse:
		$Button.scale = lerp($Button.scale, Vector2(0.8, 0.8), 0.1)
		$Button.position = lerp($Button.position, Vector2(13, 544), 0.1)
	else:
		$Button.scale = lerp($Button.scale, Vector2(0.6, 0.6), 0.1)
		$Button.position = lerp($Button.position, Vector2(12, 565), 0.1)
	
	if play_mouse:
		$Control/Play.scale = lerp($Control/Play.scale, Vector2(0.8, 0.8), 0.1)
		$Control/Play.position = lerp($Control/Play.position, Vector2(54, 203), 0.1)
	else:
		$Control/Play.scale = lerp($Control/Play.scale, Vector2(0.6, 0.6), 0.1)
		$Control/Play.position = lerp($Control/Play.position, Vector2(99, 210), 0.1)
	
	if selected_map:
		$Control.show()
		var children = $ScrollContainer/MarginContainer/VBoxContainer.get_children()
		var num = children.find(selected_map)
		
		$Control/Map.text = map_data[num][0]
		$Control/Difficulty.text = map_data[num][1]
		$Control/Description.text = map_data[num][2]
	else:
		$Control.hide()

func _on_button_mouse_entered():
	mouse = true

func _on_button_mouse_exited():
	mouse = false

func _on_button_pressed():
	get_tree().change_scene_to_file("res://MainMenu.tscn")

func _on_loop_button_pressed():
	set_button_selection($ScrollContainer/MarginContainer/VBoxContainer/TheLoop)

func _on_turns_button_pressed():
	set_button_selection($ScrollContainer/MarginContainer/VBoxContainer/TightTurns)

func _on_cross_button_pressed():
	set_button_selection($ScrollContainer/MarginContainer/VBoxContainer/CrissCross)

func set_button_selection(node):
	for panel in $ScrollContainer/MarginContainer/VBoxContainer.get_children():
		if panel == node:
			if selected_map != node:
				selected_map = node
				panel.self_modulate = selected_panel
				panel.get_child(0).self_modulate = selected_text
			else:
				selected_map = null
				panel.self_modulate = normal_panel
				panel.get_child(0).self_modulate = normal_text
		else:
			panel.self_modulate = normal_panel
			panel.get_child(0).self_modulate = normal_text

func _on_play_mouse_entered():
	play_mouse = true

func _on_play_mouse_exited():
	play_mouse = false

func _on_play_pressed():
	if selected_map == $ScrollContainer/MarginContainer/VBoxContainer/TheLoop:
		get_tree().change_scene_to_file("res://the_loop.tscn")
