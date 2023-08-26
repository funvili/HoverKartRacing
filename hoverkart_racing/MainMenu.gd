extends Control

var mouse = false

func _physics_process(delta):
	if mouse:
		$Button.scale = lerp($Button.scale, Vector2(0.85, 0.85), 0.1)
		$Button.position = lerp($Button.position, Vector2(330, 300), 0.1)
	else:
		$Button.scale = lerp($Button.scale, Vector2(0.7, 0.7), 0.1)
		$Button.position = lerp($Button.position, Vector2(370, 320), 0.1)

func _on_button_mouse_entered():
	mouse = true

func _on_button_mouse_exited():
	mouse = false

func _on_button_pressed():
	get_tree().change_scene_to_file("res://LevelSelector.tscn")
