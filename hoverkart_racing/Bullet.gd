extends RigidBody3D

func _on_area_3d_body_entered(body):
	#if I'm going to add richot, dont richot off enemies (only on walls)
	var velocity = abs(linear_velocity.x + linear_velocity.y + linear_velocity.z) / 3
	if not body.is_in_group('bullet'):
		$GpuParticles3d.emitting = true
		await get_tree().create_timer(0.8).timeout
		queue_free()

func _on_timer_timeout():
	$AnimationPlayer.play('blink_out')
	await $AnimationPlayer.animation_finished
	queue_free()
