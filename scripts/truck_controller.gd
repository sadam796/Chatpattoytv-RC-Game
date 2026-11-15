extends VehicleBody3D

const ENGINE_POWER := 145.0
const BRAKE_POWER := 24.0
const STEER_LIMIT := 0.42

var touch_steer := 0.0
var touch_throttle := 0.0
var touch_brake := 0.0
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
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		brake_input = 1.0

	steering = move_toward(steering, steer_input * STEER_LIMIT, 1.8 * delta)
	engine_force = throttle * ENGINE_POWER
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

func set_touch_controls(steer: float, throttle: float, brake_value: float) -> void:
	touch_steer = clampf(steer, -1.0, 1.0)
	touch_throttle = clampf(throttle, 0.0, 1.0)
	touch_brake = clampf(brake_value, 0.0, 1.0)

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

func _build_cameras() -> void:
	chase_camera = Camera3D.new()
	chase_camera.name = "ThirdPersonCamera"
	chase_camera.position = Vector3(0, 3.2, 6.8)
	chase_camera.rotation_degrees = Vector3(-15, 180, 0)
	chase_camera.current = true
	chase_camera.fov = 72
	add_child(chase_camera)

	bonnet_camera = Camera3D.new()
	bonnet_camera.name = "BonnetCamera"
	bonnet_camera.position = Vector3(0, 1.0, -0.62)
	bonnet_camera.rotation_degrees = Vector3(-4, 180, 0)
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
