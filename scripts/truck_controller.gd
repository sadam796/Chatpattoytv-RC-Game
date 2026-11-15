extends VehicleBody3D

const ENGINE_POWER := 145.0
const BRAKE_POWER := 24.0
const STEER_LIMIT := 0.42

var touch_steer := 0.0
var touch_throttle := 0.0
var touch_brake := 0.0
var touch_reverse := 0.0
var camera_mode := 0
var chase_camera: Camera3D
var bonnet_camera: Camera3D

func _ready() -> void:
	mass = 72.0
	linear_damp = 0.08
	angular_damp = 1.4
	center_of_mass = Vector3(0, -0.28, 0.02)
	_build_body()
	_build_wheels()
	_build_suspension_details()
	_build_cameras()
	_make_truck_lights()

func _physics_process(delta: float) -> void:
	var steer_input := 0.0
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		steer_input -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		steer_input += 1.0
	steer_input = clampf(steer_input + touch_steer, -1.0, 1.0)

	var throttle := touch_throttle
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		throttle = 1.0
	var brake_input := touch_brake
	var reverse_input := touch_reverse
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		if linear_velocity.length() < 1.0:
			reverse_input = 1.0
		else:
			brake_input = 1.0

	steering = move_toward(steering, steer_input * STEER_LIMIT, 1.8 * delta)
	engine_force = throttle * ENGINE_POWER - reverse_input * ENGINE_POWER * 0.62
	brake = brake_input * BRAKE_POWER

	if Input.is_key_pressed(KEY_C):
		if not _camera_key_was_down:
			toggle_camera()
		_camera_key_was_down = true
	else:
		_camera_key_was_down = false
	if Input.is_key_pressed(KEY_R):
		if not _reset_key_was_down:
			reset_vehicle()
		_reset_key_was_down = true
	else:
		_reset_key_was_down = false

var _camera_key_was_down := false
var _reset_key_was_down := false

func set_touch_controls(steer: float, throttle: float, brake_value: float, reverse_value: float) -> void:
	touch_steer = clampf(steer, -1.0, 1.0)
	touch_throttle = clampf(throttle, 0.0, 1.0)
	touch_brake = clampf(brake_value, 0.0, 1.0)
	touch_reverse = clampf(reverse_value, 0.0, 1.0)

func toggle_camera() -> void:
	camera_mode = 1 - camera_mode
	chase_camera.current = camera_mode == 0
	bonnet_camera.current = camera_mode == 1

func reset_vehicle() -> void:
	global_position += Vector3(0, 2.2, 0)
	rotation = Vector3(0, rotation.y, 0)
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO

func _build_body() -> void:
	var collision := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(1.55, 0.42, 2.05)
	collision.shape = box
	collision.position.y = 0.30
	add_child(collision)

	var shell := MeshInstance3D.new()
	var body_mesh := BoxMesh.new()
	body_mesh.size = Vector3(1.62, 0.42, 2.12)
	shell.mesh = body_mesh
	shell.position.y = 0.32
	var shell_mat := StandardMaterial3D.new()
	shell_mat.albedo_color = Color(0.78, 0.12, 0.055)
	shell_mat.metallic = 0.28
	shell_mat.roughness = 0.32
	shell.material_override = shell_mat
	add_child(shell)

	var cabin := MeshInstance3D.new()
	var cabin_mesh := BoxMesh.new()
	cabin_mesh.size = Vector3(1.22, 0.42, 0.92)
	cabin.mesh = cabin_mesh
	cabin.position = Vector3(0, 0.72, 0.10)
	var cabin_mat := StandardMaterial3D.new()
	cabin_mat.albedo_color = Color(0.08, 0.11, 0.14)
	cabin_mat.metallic = 0.18
	cabin_mat.roughness = 0.25
	cabin.material_override = cabin_mat
	add_child(cabin)

	var bumper := MeshInstance3D.new()
	var bumper_mesh := BoxMesh.new()
	bumper_mesh.size = Vector3(1.78, 0.18, 0.18)
	bumper.mesh = bumper_mesh
	bumper.position = Vector3(0, 0.10, -1.10)
	var bumper_mat := StandardMaterial3D.new()
	bumper_mat.albedo_color = Color(0.045, 0.05, 0.055)
	bumper_mat.metallic = 0.65
	bumper_mat.roughness = 0.3
	bumper.material_override = bumper_mat
	add_child(bumper)

	# Detailed RC shell: hood, fenders, glass, grille, roll cage and side protection.
	_add_box_part("Hood", Vector3(1.34, 0.13, 0.72), Vector3(0, 0.58, -0.60), Color(0.86, 0.16, 0.075), 0.30)
	_add_box_part("RearDeck", Vector3(1.34, 0.12, 0.52), Vector3(0, 0.56, 0.78), Color(0.68, 0.09, 0.045), 0.34)
	_add_box_part("FrontGrille", Vector3(0.76, 0.24, 0.045), Vector3(0, 0.31, -1.19), Color(0.018, 0.024, 0.03), 0.55)
	for i in 4:
		_add_box_part("GrilleSlat_%d" % i, Vector3(0.68, 0.018, 0.018), Vector3(0, 0.23 + i * 0.052, -1.218), Color(0.42, 0.46, 0.48), 0.65)
	for side in [-1.0, 1.0]:
		_add_box_part("FrontFender_%s" % side, Vector3(0.34, 0.16, 0.94), Vector3(side * 0.91, 0.42, -0.72), Color(0.09, 0.105, 0.12), 0.42)
		_add_box_part("RearFender_%s" % side, Vector3(0.34, 0.16, 0.94), Vector3(side * 0.91, 0.42, 0.76), Color(0.09, 0.105, 0.12), 0.42)
		_add_box_part("SideRail_%s" % side, Vector3(0.10, 0.14, 1.52), Vector3(side * 0.86, 0.06, 0.04), Color(0.035, 0.045, 0.052), 0.62)
		_add_box_part("SideWindow_%s" % side, Vector3(0.035, 0.28, 0.58), Vector3(side * 0.63, 0.76, 0.12), Color(0.035, 0.12, 0.17), 0.18)
		_add_box_part("Headlight_%s" % side, Vector3(0.24, 0.14, 0.055), Vector3(side * 0.53, 0.43, -1.19), Color(0.92, 0.82, 0.57), 0.18)
		_add_box_part("RoofRail_%s" % side, Vector3(0.075, 0.07, 0.92), Vector3(side * 0.60, 1.00, 0.10), Color(0.035, 0.045, 0.052), 0.55)
	_add_box_part("Windshield", Vector3(1.08, 0.30, 0.035), Vector3(0, 0.79, -0.39), Color(0.035, 0.12, 0.17), 0.16, Vector3(-18, 0, 0))
	_add_box_part("RearWindow", Vector3(1.02, 0.27, 0.035), Vector3(0, 0.79, 0.59), Color(0.035, 0.12, 0.17), 0.16, Vector3(18, 0, 0))
	for i in 3:
		_add_box_part("HoodVent_%d" % i, Vector3(0.10, 0.025, 0.30), Vector3(-0.25 + i * 0.25, 0.66, -0.60), Color(0.035, 0.04, 0.045), 0.7)

func _add_box_part(part_name: String, dimensions: Vector3, local_pos: Vector3, tint: Color, metal: float, rotation_deg: Vector3 = Vector3.ZERO) -> void:
	var part := MeshInstance3D.new()
	part.name = part_name
	var mesh := BoxMesh.new()
	mesh.size = dimensions
	part.mesh = mesh
	part.position = local_pos
	part.rotation_degrees = rotation_deg
	var mat := StandardMaterial3D.new()
	mat.albedo_color = tint
	mat.metallic = metal
	mat.roughness = 0.34 if metal > 0.2 else 0.55
	part.material_override = mat
	add_child(part)

func _build_wheels() -> void:
	for axle in 2:
		for side in [-1.0, 1.0]:
			var wheel := VehicleWheel3D.new()
			wheel.name = ("Front" if axle == 0 else "Rear") + ("Left" if side < 0 else "Right")
			wheel.position = Vector3(side * 0.91, -0.02, -0.72 if axle == 0 else 0.76)
			wheel.use_as_steering = axle == 0
			wheel.use_as_traction = true
			wheel.wheel_radius = 0.58
			wheel.wheel_rest_length = 0.24
			wheel.suspension_travel = 0.30
			wheel.suspension_stiffness = 24.0
			wheel.damping_compression = 0.55
			wheel.damping_relaxation = 0.72
			wheel.wheel_friction_slip = 4.2
			wheel.wheel_roll_influence = 0.12
			add_child(wheel)
			_add_wheel_visual(wheel)

func _add_wheel_visual(wheel: VehicleWheel3D) -> void:
	var tyre := MeshInstance3D.new()
	var cylinder := CylinderMesh.new()
	cylinder.top_radius = 0.58
	cylinder.bottom_radius = 0.58
	cylinder.height = 0.36
	cylinder.radial_segments = 24
	tyre.mesh = cylinder
	tyre.rotation_degrees.z = 90
	var tyre_mat := StandardMaterial3D.new()
	tyre_mat.albedo_color = Color(0.035, 0.04, 0.045)
	tyre_mat.roughness = 0.96
	tyre.material_override = tyre_mat
	wheel.add_child(tyre)

	# Deep beadlock-style rim and central hub.
	var rim := MeshInstance3D.new()
	var rim_mesh := CylinderMesh.new()
	rim_mesh.top_radius = 0.31
	rim_mesh.bottom_radius = 0.31
	rim_mesh.height = 0.385
	rim_mesh.radial_segments = 24
	rim.mesh = rim_mesh
	rim.rotation_degrees.z = 90
	var rim_mat := StandardMaterial3D.new()
	rim_mat.albedo_color = Color(0.12, 0.15, 0.17)
	rim_mat.metallic = 0.82
	rim_mat.roughness = 0.28
	rim.material_override = rim_mat
	wheel.add_child(rim)

	var hub := MeshInstance3D.new()
	var hub_mesh := CylinderMesh.new()
	hub_mesh.top_radius = 0.12
	hub_mesh.bottom_radius = 0.12
	hub_mesh.height = 0.405
	hub_mesh.radial_segments = 16
	hub.mesh = hub_mesh
	hub.rotation_degrees.z = 90
	var hub_mat := StandardMaterial3D.new()
	hub_mat.albedo_color = Color(0.78, 0.42, 0.08)
	hub_mat.metallic = 0.72
	hub_mat.roughness = 0.26
	hub.material_override = hub_mat
	wheel.add_child(hub)

	# Chunky tread blocks around the tyre circumference.
	for tread_index in 12:
		var lug := MeshInstance3D.new()
		var lug_mesh := BoxMesh.new()
		lug_mesh.size = Vector3(0.39, 0.12, 0.105)
		lug.mesh = lug_mesh
		var angle := TAU * float(tread_index) / 12.0
		lug.position = Vector3(0, sin(angle) * 0.555, cos(angle) * 0.555)
		lug.rotation.x = angle
		var lug_mat := StandardMaterial3D.new()
		lug_mat.albedo_color = Color(0.045, 0.05, 0.052)
		lug_mat.roughness = 1.0
		lug.material_override = lug_mat
		wheel.add_child(lug)

func _build_suspension_details() -> void:
	# Visible long-travel dampers mounted near each wheel.
	for axle in 2:
		for side in [-1.0, 1.0]:
			var shock := MeshInstance3D.new()
			shock.name = "Shock_%d_%s" % [axle, side]
			var shock_mesh := CylinderMesh.new()
			shock_mesh.top_radius = 0.055
			shock_mesh.bottom_radius = 0.055
			shock_mesh.height = 0.58
		shock.mesh = shock_mesh
		shock.position = Vector3(side * 0.70, 0.02, -0.72 if axle == 0 else 0.76)
		shock.rotation_degrees.z = side * -12.0
		var shock_mat := StandardMaterial3D.new()
		shock_mat.albedo_color = Color(0.72, 0.75, 0.77)
		shock_mat.metallic = 0.88
		shock_mat.roughness = 0.22
		shock.material_override = shock_mat
		add_child(shock)
		var spring := MeshInstance3D.new()
		var spring_mesh := TorusMesh.new()
		spring_mesh.inner_radius = 0.065
		spring_mesh.outer_radius = 0.105
		spring_mesh.rings = 8
		spring_mesh.ring_segments = 12
		spring.mesh = spring_mesh
		spring.position = shock.position
		var spring_mat := StandardMaterial3D.new()
		spring_mat.albedo_color = Color(0.82, 0.34, 0.06)
		spring_mat.metallic = 0.65
		spring_mat.roughness = 0.3
		spring.material_override = spring_mat
		add_child(spring)

func _build_cameras() -> void:
	chase_camera = Camera3D.new()
	chase_camera.name = "ThirdPersonCamera"
	chase_camera.position = Vector3(0, 3.2, 6.8)
	chase_camera.rotation_degrees = Vector3(-15, 0, 0)
	chase_camera.current = true
	chase_camera.fov = 72
	add_child(chase_camera)

	bonnet_camera = Camera3D.new()
	bonnet_camera.name = "BonnetCamera"
	bonnet_camera.position = Vector3(0, 1.0, -0.62)
	bonnet_camera.rotation_degrees = Vector3(-4, 0, 0)
	bonnet_camera.current = false
	bonnet_camera.fov = 82
	add_child(bonnet_camera)

func _make_truck_lights() -> void:
	for side in [-1.0, 1.0]:
		var lamp := OmniLight3D.new()
		lamp.position = Vector3(side * 0.48, 0.38, -1.12)
		lamp.light_color = Color(1.0, 0.82, 0.58)
		lamp.light_energy = 0.35
		lamp.omni_range = 4.0
		add_child(lamp)
