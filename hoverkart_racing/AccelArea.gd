extends Area3D

func _physics_process(delta):
	if get_overlapping_bodies().has($"../Kart"):
		var dir = (transform.basis * Vector3(0, 0, 1)).normalized()
		$"../Kart".apply_force(dir * 400, $"../Kart".center_of_mass)
		print('exterior accelerating!')
