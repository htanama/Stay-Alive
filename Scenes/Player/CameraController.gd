extends Node3D

const MOUSE_SENSITIVITY = 0.002
# The maximum angle the camera can look up (90 degrees) or down (-90 degrees)
const PITCH_LIMIT_DEGREES = 45.0 

func _ready() -> void:
	# Captures the mouse, hiding it and locking it to the center of the screen
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent) -> void:
	# Only handle mouse movement events when the mouse is captured
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		
		# 1. Apply vertical rotation (Pitch)
		# We use rotate_x() because the local X-axis determines pitch (up/down).
		# We multiply by -1 to invert the mouse Y movement (pull down looks up, push up looks down).
		rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		
		# 2. Clamp the rotation (prevent flipping)
		# Convert degrees to radians for the clamping function
		var min_pitch_rad = deg_to_rad(-PITCH_LIMIT_DEGREES)
		var max_pitch_rad = deg_to_rad(PITCH_LIMIT_DEGREES)
		
		# Get the current X-axis rotation and clamp it
		rotation.x = clampf(rotation.x, min_pitch_rad, max_pitch_rad)
		

func _unhandled_input(event: InputEvent) -> void:
	# Pressing ESC releases the mouse
	if event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
