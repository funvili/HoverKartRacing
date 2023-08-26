extends VehicleBody3D

#less controls and more compact (later on)
#cam shake
#big thingys (boulders) that chase you and kill you when the catch up or other karts
#no damage bullets that can be used to flip yout kart while damage bullets harm your kart

@onready var cam: Camera3D = $SpringArm3d/Camera3d
@onready var turret_base: MeshInstance3D = $Cube/Turret/Cube003
@onready var turret: MeshInstance3D = $Cube/Turret/Cube003/Cube
@onready var turret2: MeshInstance3D = $Cube/Turret2/Cube


@onready var bullet = preload("res://Bullet.tscn")
@onready var missile = preload("res://Missile.tscn")

var steer = 1
var flash = false
var flash2 = false

var stabalizers = true

var drifting = false
var no_friction = false
var tight_turn = false

func _physics_process(delta):
	if Input.is_action_just_pressed("restart"):
		position = Vector3(-100, 5, 0)
		rotation = Vector3.ZERO
		linear_velocity = Vector3.ZERO
		angular_velocity = Vector3.ZERO
	
	# you dont always have nitro
	set_engine_force(lerp(get_engine_force(), Input.get_axis("deaccelerate", "accelerate") * (400 - (Input.get_action_strength('deaccelerate') * 300)), 0.3))
	set_steering(lerp(get_steering(), Input.get_axis("right", "left") * steer, 0.05))
	print(rad_to_deg(steering))
	
	#do more in your power to unflip the car!
	apply_torque(Vector3(-rad_to_deg(rotation.x), 0, -rad_to_deg(rotation.z)) * 2 * bool_to_int(stabalizers))
	apply_torque(Vector3(Input.get_axis("up", "down"), Input.get_axis("right", "left"), Input.get_axis("rollL", "rollR")) * 150 * wheels_in_contact())
	var dir = (transform.basis * Vector3(Input.get_axis("VR", "VL"), 0, 0)).normalized()
	apply_force(dir * 2000, center_of_mass)
	dir = (transform.basis * Vector3(0, 0, Input.get_action_strength("nitro"))).normalized()
	apply_force(dir * 400, center_of_mass)
	
	if Input.is_action_just_pressed("nitro"):
		if $DoubleClickJump.is_stopped():
			$DoubleClickJump.start()
		else:
			dir = (transform.basis * Vector3(0, 1, 0)).normalized()
			apply_force(dir * 15000, center_of_mass)
	
	if Input.is_action_just_pressed("stabalizers"):
		stabalizers = not stabalizers
	
	if Input.is_action_just_pressed("drift"):
		if $DoubleClickDrift.is_stopped():
			$DoubleClickDrift.start()
		else:
			if Input.is_action_pressed("accelerate"):
				drifting  = true
			else:
				tight_turn = true
				steer = deg_to_rad(70)
	if not Input.is_action_pressed("drift"):
		tight_turn = false
		drifting = false
	
	if Input.is_action_just_pressed("deaccelerate"):
		if $DoubleClickFriction.is_stopped():
			$DoubleClickFriction.start()
		else:
			no_friction = true
	if not Input.is_action_pressed("deaccelerate"):
		no_friction = false
	
	if no_friction:
		print('no friction!')
		$FL.wheel_friction_slip = 0
		$FR.wheel_friction_slip = 0
		$BL.wheel_friction_slip = 0
		$BR.wheel_friction_slip = 0
	elif drifting:
		#drifting is a bit wonky, tweak these (I give up, I'll find out later :)
		if not tight_turn:
			steer = deg_to_rad(65)
		$FL.wheel_friction_slip = 2
		$FR.wheel_friction_slip = 2
		$BL.wheel_friction_slip = 1
		$BR.wheel_friction_slip = 1
	else:
		if not tight_turn:
			steer = deg_to_rad(65)
		$FL.wheel_friction_slip = 5
		$FR.wheel_friction_slip = 5
		$BL.wheel_friction_slip = 5
		$BR.wheel_friction_slip = 5
	
	dir = ((transform.basis * Vector3(1, 1, 1)).normalized() * linear_velocity).z #need to get the forward velocity
	$SpringArm3d.position = lerp($SpringArm3d.position, Vector3(position.x, position.y + 2, position.z), 0.3)
	$SpringArm3d.rotation.x = lerp_angle($SpringArm3d.rotation.x, rotation.x + deg_to_rad(-15), 0.15)
	$SpringArm3d.rotation.y = lerp_angle($SpringArm3d.rotation.y, rotation.y + (deg_to_rad(180) * bool_to_int(true)), 0.15)
	$SpringArm3d.rotation.z = lerp_angle($SpringArm3d.rotation.z, rotation.z, 0.15)
	
	$Cube.rotation.x = lerp($Cube.rotation.x, deg_to_rad(Input.get_axis("right", "left") * -8), 0.15)
	$CollisionShape3d.rotation.x = lerp($CollisionShape3d.rotation.x, deg_to_rad(Input.get_axis("right", "left") * -8), 0.15)
	
	if get_mouse_pos():
		$Cube/Turret/Cube003/Cube/RayCast3d.target_position.z = -20000
		$Cube/Turret/Cube003/Cube/RayCast3d.look_at(get_mouse_pos())
		
		$Cube/Turret/CsgBox3d.show()
		if $Cube/Turret/Cube003/Cube/RayCast3d.get_collision_point():
			$Cube/Turret/CsgBox3d.global_position = $Cube/Turret/Cube003/Cube/RayCast3d.get_collision_point()
		$Cube/Turret/Lookat.look_at(get_mouse_pos())
		
		turret_base.rotation.y = lerp_angle(turret_base.rotation.y, $Cube/Turret/Lookat.rotation.y, 0.15)
		turret.rotation.x = lerp_angle(turret.rotation.x, $Cube/Turret/Lookat.rotation.x + deg_to_rad(180), 0.15)
		
		$TurretCollision.rotation.y = turret_base.rotation.y
		$TurretCollision.rotation.x = turret.rotation.x
		$TurretCollision.global_position = turret.global_position
		
		#2nd turret
		$Cube/Turret2/Cube/RayCast3d.target_position.z = -20000
		$Cube/Turret2/Cube/RayCast3d.look_at(get_mouse_pos())
		
		$Cube/Turret2/CsgBox3d.show()
		if $Cube/Turret2/Cube/RayCast3d.get_collision_point():
			$Cube/Turret2/CsgBox3d.global_position = $Cube/Turret2/Cube/RayCast3d.get_collision_point()
		$Cube/Turret2/Lookat.look_at(get_mouse_pos())
		
		turret2.rotation.x = lerp_angle(turret2.rotation.x, $Cube/Turret2/Lookat.rotation.x + deg_to_rad(180), 0.15)
		turret2.rotation.y = lerp_angle(turret2.rotation.y, $Cube/Turret2/Lookat.rotation.y, 0.15)
		
		if Input.is_action_pressed('shoot'):
			if $Cube/Turret/Cooldown.is_stopped() and $Cube/Turret/Cube003/Cube/RayCast3d.get_collider() != self:
				var instance = bullet.instantiate()
				$Cube/Turret/Cube003/Cube/Cube002.add_child(instance)
				instance.top_level = true
				var instance_dir = (instance.transform.basis * Vector3(0, 0, 1)).normalized()
				instance.apply_force(instance_dir * 5000, instance.center_of_mass)
				$Cube/Turret/Cooldown.start()
				#I am gettings lazyies, get rid of recoil if it dosent work, recoil becomes a big problem when doing stunts too
				#apply_force($Cube/Turret/Lookat.global_rotation * -500, $TurretCollision.position)
				$Cube/Turret/Cube003/Cube/Flash/CsgBox3d2.rotation += Vector3(deg_to_rad(10), deg_to_rad(10), deg_to_rad(10))
				$Cube/Turret/Cube003/Cube/Flash/CsgBox3d3.rotation += Vector3(deg_to_rad(10), deg_to_rad(10), deg_to_rad(10))
				$Cube/Turret/Cube003/Cube/Flash/CsgBox3d4.rotation += Vector3(deg_to_rad(10), deg_to_rad(10), deg_to_rad(10))
				if $Cube/Turret/Cube003/Cube/Flash/Timer.is_stopped():
					$Cube/Turret/Cube003/Cube/Flash/Timer.start()
					flash = not flash
			
			#2nd turret
			if $Cube/Turret2/Cooldown.is_stopped() and $Cube/Turret2/Cube/RayCast3d.get_collider() != self:
				var instance = bullet.instantiate()
				$Cube/Turret2/Cube/Cube001.add_child(instance)
				instance.top_level = true
				var instance_dir = (instance.transform.basis * Vector3(0, 0, 1)).normalized()
				instance.apply_force(instance_dir * 5000, instance.center_of_mass)
				$Cube/Turret2/Cooldown.start()
				#I am gettings lazyies, get rid of recoil if it dosent work, recoil becomes a big problem when doing stunts too
				#apply_force($Cube/Turret/Lookat.global_rotation * -500, $TurretCollision.position)
				$Cube/Turret2/Cube/Flash/CsgBox3d2.rotation += Vector3(deg_to_rad(10), deg_to_rad(10), deg_to_rad(10))
				$Cube/Turret2/Cube/Flash/CsgBox3d3.rotation += Vector3(deg_to_rad(10), deg_to_rad(10), deg_to_rad(10))
				$Cube/Turret2/Cube/Flash/CsgBox3d4.rotation += Vector3(deg_to_rad(10), deg_to_rad(10), deg_to_rad(10))
				if $Cube/Turret2/Cube/Flash/Timer.is_stopped():
					$Cube/Turret2/Cube/Flash/Timer.start()
					flash2 = not flash2
		else:
			flash = false
			flash2 = false
	else:
		$Cube/Turret/CsgBox3d.hide()
		$Cube/Turret2/CsgBox3d.hide()
		flash = false
		flash2 = false
	
	$Cube/Turret/Cube003/Cube/Flash.visible = flash
	$Cube/Turret2/Cube/Flash.visible = flash2
	
	if Input.is_action_just_pressed("missile"): #add cooldown
		var instance = missile.instantiate()
		add_child(instance)
		instance.position = Vector3(1, 0, 0.2)
		instance.top_level = true
		
		instance = missile.instantiate()
		add_child(instance)
		instance.position = Vector3(-1, 0, 0.2)
		instance.top_level = true
	
	if Input.is_action_pressed("zoom") and get_mouse_pos(): #fix, it looks weird
		var normal = $Cube/Turret/Lookat.rotation
		cam.rotation.x = lerp_angle(cam.rotation.x, normal.x, 0.15)
		cam.rotation.y = lerp_angle(cam.rotation.y, normal.y + deg_to_rad(180), 0.15)
		cam.fov = 50
	else:
		cam.look_at(position)
		cam.fov = 90
	
	#idk why 4-wheel drive is not working, brakes do goofy stuff
	#if Input.is_action_just_pressed("all_drive"):
		#$FL.set_use_as_traction(not $FL.is_used_as_traction())
		#$FR.set_use_as_traction(not $FR.is_used_as_traction())
	
	$FL.set_brake(5 * Input.get_action_strength("brakes"))
	$FR.set_brake(5 * Input.get_action_strength("brakes"))
	
	$Cube/Turret/CsgBox3d.global_rotation = rotation
	$Cube/Turret2/CsgBox3d.global_rotation = rotation
	$VelCube.position = (linear_velocity / 5) + position
	$VelCube.rotation = angular_velocity

func wheels_in_contact() -> int:
	if $BL.is_in_contact():
		return 0
	elif $FL.is_in_contact():
		return 0
	elif $FR.is_in_contact():
		return 0
	elif $BR.is_in_contact():
		return 0
	else:
		return 1

func get_mouse_pos():
	var par = PhysicsRayQueryParameters3D.new()
	cam = get_tree().root.get_camera_3d()
	par.from = cam.project_ray_origin(get_viewport().get_mouse_position())
	par.to = par.from + cam.project_ray_normal(get_viewport().get_mouse_position()) * 20000
	var ray = get_world_3d().direct_space_state.intersect_ray(par)
	
	if ray.has('position'):
		return ray['position']
	else:
		return null

func bool_to_int(b: bool) -> int:
	if b:
		return 1
	else:
		return 0
