extends Node3D

#turrets have a weakness, they can be killed

@onready var bullet = preload("res://Bullet.tscn")

func _physics_process(delta):
	$lookat.look_at($"../Kart/VelCube".position)
	$RayCast3d.look_at($"../Kart".position)
	
	if $RayCast3d.get_collider() == $"../Kart":
		$Cube003.rotation.y = lerp_angle($Cube003.rotation.y, $lookat.rotation.y, 0.15)
		$Cube003/Cube.rotation.x = lerp_angle($Cube003/Cube.rotation.x, $lookat.rotation.x + deg_to_rad(180), 0.15)
		
		if $Cooldown.is_stopped():
			var instance = bullet.instantiate()
			$Cube003/Cube/Cube002.add_child(instance)
			instance.top_level = true
			var instance_dir = (instance.transform.basis * Vector3(0, 0, 1)).normalized()
			instance.apply_force(instance_dir * 5000, instance.center_of_mass)
			$Cooldown.start()
		
		$Cube003/Cube/Flash/CsgBox3d2.rotation += Vector3(deg_to_rad(10), deg_to_rad(10), deg_to_rad(10))
		$Cube003/Cube/Flash/CsgBox3d3.rotation += Vector3(deg_to_rad(10), deg_to_rad(10), deg_to_rad(10))
		$Cube003/Cube/Flash/CsgBox3d4.rotation += Vector3(deg_to_rad(10), deg_to_rad(10), deg_to_rad(10))
		if $Cube003/Cube/Flash/Timer.is_stopped():
			$Cube003/Cube/Flash/Timer.start()
			$Cube003/Cube/Flash.visible = not $Cube003/Cube/Flash.visible
	else:
		$Cube003/Cube/Flash.hide()
