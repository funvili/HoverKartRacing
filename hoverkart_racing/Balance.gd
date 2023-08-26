extends RigidBody3D

func _physics_process(delta):
	apply_torque(Vector3(rotation.x, 0, rotation.z) * -100)
