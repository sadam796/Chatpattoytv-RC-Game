extends CanvasLayer

signal camera_requested
signal reset_requested
signal drive_changed(steer: float, throttle: float, brake_value: float, reverse_value: float)

var steer_value := 0.0
var throttle_value := 0.0
var brake_value := 0.0
var reverse_value := 0.0

func _ready() -> void:
	_build_hud()

func _process(_delta: float) -> void:
	drive_changed.emit(steer_value, throttle_value, brake_value, reverse_value)

func _build_hud() -> void:
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(root)

	var title := Label.new()
	title.text = "CHATPATTOYTV  /  RC OFF-ROAD"
	title.position = Vector2(24, 20)
	title.add_theme_font_size_override("font_size", 18)
	title.add_theme_color_override("font_color", Color(1, 1, 1, 0.92))
	root.add_child(title)

	var camera_button := _make_button("CAM", Vector2(-118, 24), Vector2(92, 48), root)
	camera_button.anchor_left = 1.0
	camera_button.anchor_right = 1.0
	camera_button.pressed.connect(func(): camera_requested.emit())

	var reset_button := _make_button("RESET", Vector2(-118, 82), Vector2(92, 42), root)
	reset_button.anchor_left = 1.0
	reset_button.anchor_right = 1.0
	reset_button.pressed.connect(func(): reset_requested.emit())

	var left_button := _make_button("◀", Vector2(28, -112), Vector2(76, 76), root)
	left_button.anchor_top = 1.0
	left_button.anchor_bottom = 1.0
	left_button.button_down.connect(func(): steer_value = -1.0)
	left_button.button_up.connect(func(): steer_value = 0.0)

	var right_button := _make_button("▶", Vector2(114, -112), Vector2(76, 76), root)
	right_button.anchor_top = 1.0
	right_button.anchor_bottom = 1.0
	right_button.button_down.connect(func(): steer_value = 1.0)
	right_button.button_up.connect(func(): steer_value = 0.0)

	var brake_button := _make_button("BRAKE", Vector2(-210, -112), Vector2(88, 76), root)
	brake_button.anchor_left = 1.0
	brake_button.anchor_right = 1.0
	brake_button.anchor_top = 1.0
	brake_button.anchor_bottom = 1.0
	brake_button.button_down.connect(func(): brake_value = 1.0)
	brake_button.button_up.connect(func(): brake_value = 0.0)

	var reverse_button := _make_button("REVERSE", Vector2(-112, -196), Vector2(104, 62), root)
	reverse_button.anchor_left = 1.0
	reverse_button.anchor_right = 1.0
	reverse_button.anchor_top = 1.0
	reverse_button.anchor_bottom = 1.0
	reverse_button.button_down.connect(func(): reverse_value = 1.0)
	reverse_button.button_up.connect(func(): reverse_value = 0.0)

	var throttle_button := _make_button("THROTTLE", Vector2(-112, -112), Vector2(104, 76), root)
	throttle_button.anchor_left = 1.0
	throttle_button.anchor_right = 1.0
	throttle_button.anchor_top = 1.0
	throttle_button.anchor_bottom = 1.0
	throttle_button.button_down.connect(func(): throttle_value = 1.0)
	throttle_button.button_up.connect(func(): throttle_value = 0.0)

func _make_button(caption: String, offset: Vector2, button_size: Vector2, parent: Control) -> Button:
	var button := Button.new()
	button.text = caption
	button.position = offset
	button.size = button_size
	button.add_theme_font_size_override("font_size", 17)
	button.add_theme_color_override("font_color", Color.WHITE)
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.035, 0.065, 0.095, 0.78)
	normal.border_color = Color(0.95, 0.62, 0.12, 0.9)
	normal.set_border_width_all(2)
	normal.set_corner_radius_all(12)
	button.add_theme_stylebox_override("normal", normal)
	var pressed := normal.duplicate()
	pressed.bg_color = Color(0.72, 0.25, 0.055, 0.95)
	button.add_theme_stylebox_override("pressed", pressed)
	parent.add_child(button)
	return button
