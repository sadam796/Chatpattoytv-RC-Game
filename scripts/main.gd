extends Node3D

const TruckController = preload("res://scripts/truck_controller.gd")
const MobileHUD = preload("res://scripts/mobile_hud.gd")

var truck: VehicleBody3D

func _ready() -> void:
	_build_world()
	truck = TruckController.new()
	truck.name = "RC_Monster_Truck"
	add_child(truck)
	truck.global_position = Vector3(0.0, 2.0, 0.0)
	var hud = MobileHUD.new()
	add_child(hud)
	hud.camera_requested.connect(truck.toggle_camera)
	hud.reset_requested.connect(truck.reset_vehicle)
	hud.drive_changed.connect(truck.set_touch_controls)
	_setup_environment()

func _build_world() -> void:
	var ground_body := StaticBody3D.new()
	ground_body.name = "Offroad_Ground"
	add_child(ground_body)
	var ground_shape := CollisionShape3D.new()
	var ground_box := BoxShape3D.new()
	ground_box.size = Vector3(180.0, 1.0, 180.0)
	ground_shape.shape = ground_box
	ground_shape.position.y = -0.5
	ground_body.add_child(ground_shape)
	var ground_mesh := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(180.0, 180.0)
	ground_mesh.mesh = plane
	var dirt := StandardMaterial3D.new()
	dirt.albedo_color = Color(0.25, 0.20, 0.14)
	dirt.roughness = 1.0
	ground_mesh.material_override = dirt
	ground_mesh.position.y = 0.01
	ground_body.add_child(ground_mesh)

	_add_ramp(Vector3(0, 0, -15), Vector3(5, 1.0, 8), -0.24)
	_add_ramp(Vector3(12, 0, -28), Vector3(7, 1.2, 10), -0.30)
	_add_rock(Vector3(-8, 0.9, -8), Vector3(2.0, 1.8, 2.2))
	_add_rock(Vector3(9, 0.7, 7), Vector3(2.4, 1.4, 1.8))
	_add_rock(Vector3(-14, 0.6, -24), Vector3(3.0, 1.2, 2.5))
	_add_trail_marker(Vector3(0, 0.04, -42))

func _add_ramp(pos: Vector3, size: Vector3, pitch: float) -> void:
	var body := StaticBody3D.new()
	body.position = pos
	body.rotation.x = pitch
	add_child(body)
	var shape_node := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	shape_node.shape = shape
	body.add_child(shape_node)
	var mesh_node := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh_node.mesh = mesh
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.30, 0.25, 0.18)
	mat.roughness = 0.95
	mesh_node.material_override = mat
	body.add_child(mesh_node)

func _add_rock(pos: Vector3, size: Vector3) -> void:
	var body := StaticBody3D.new()
	body.position = pos
	add_child(body)
	var shape_node := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	shape_node.shape = shape
	body.add_child(shape_node)
	var mesh_node := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh_node.mesh = mesh
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.24, 0.25, 0.23)
	mat.roughness = 1.0
	mesh_node.material_override = mat
	body.add_child(mesh_node)

func _add_trail_marker(pos: Vector3) -> void:
	var marker := MeshInstance3D.new()
	var ring := TorusMesh.new()
	ring.inner_radius = 1.8
	ring.outer_radius = 2.0
	marker.mesh = ring
	marker.position = pos
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(1.0, 0.68, 0.12)
	mat.emission_enabled = true
	mat.emission = Color(0.8, 0.35, 0.03)
	marker.material_override = mat
	add_child(marker)

func _setup_environment() -> void:
	var world_env := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	var sky := Sky.new()
	var sky_mat := ProceduralSkyMaterial.new()
	sky_mat.sky_top_color = Color(0.12, 0.28, 0.48)
	sky_mat.sky_horizon_color = Color(0.66, 0.72, 0.74)
	sky.sky_material = sky_mat
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	world_env.environment = env
	add_child(world_env)

	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-48, -28, 0)
	sun.light_energy = 1.15
	sun.shadow_enabled = true
	add_child(sun)
