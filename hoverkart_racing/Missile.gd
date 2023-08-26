extends RigidBody3D

func _process(delta):
	var dir = (transform.basis * Vector3(0, 0, 1)).normalized()
	apply_force(dir * 1000, center_of_mass)

func _on_area_3d_body_entered(body):
	if body.name != 'Kart':
		$Area3d2.monitoring = true
		$GpuParticles3d2.emitting = true
		$Area3d.top_level = true
		
		$Cube.hide()
		$GpuParticles3d.hide()
		await get_tree().create_timer(1.2).timeout
		queue_free()


func _on_area_3d_2_body_entered(body):
	if body.name == 'Kart':
		$Area3d2/look_at.look_at(body.position)
		var dir = ($Area3d2/look_at.transform.basis * Vector3(0, 0, 1)).normalized()
		body.apply_force(-dir * 10000, body.center_of_mass)
