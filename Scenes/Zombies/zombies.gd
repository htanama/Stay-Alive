extends CharacterBody3D

@export var speed: float = 3.0
@export var rotation_speed: float = 5.0
@export var night_start: float = 0.75 # 75% through the day (Dusk)
@export var night_end: float = 0.25  # 25% through the day (Dawn)

# Path to the Player and the Light Source
const PLAYER_PATH = "../Player" 
# Change this path to your DirectionalLight3D node (e.g., "../DirectionalLight3D")
const LIGHT_PATH = "../DirectionalLight3D" 

var player: Node3D = null
var directional_light: DirectionalLight3D = null

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready() -> void:
	# Find the Player
	player = get_node_or_null(PLAYER_PATH)
	if not player:
		print("ERROR: Player node not found at path: ", PLAYER_PATH)
		
	# Find the Directional Light and its script
	directional_light = get_node_or_null(LIGHT_PATH)
	if not directional_light:
		print("ERROR: DirectionalLight3D not found at path: ", LIGHT_PATH)
		# We allow the script to continue, but chasing will be disabled.


# --- New Logic: Check if it's Night ---
func is_nighttime() -> bool:
	if not directional_light or not directional_light.has_method("get_time_of_day"):
		# If the light or the script isn't found, assume day to be safe.
		return false

	var current_time = directional_light.get_time_of_day()

	# Night is defined as time being after night_start OR before night_end
	# (e.g., 0.75 to 1.0, and 0.0 to 0.25)
	#return current_time >= night_start or current_time < night_end
	
	return true

func _physics_process(delta: float) -> void:
	if not player:
		return

	# 1. Apply Gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	# 2. Conditional Chasing
	if is_nighttime():
		# --- Chasing Logic (Only runs at night) ---
		var direction_to_player = (player.global_position - global_position).normalized()
		var target_horizontal_position = Vector3(player.global_position.x, global_position.y, player.global_position.z)
		var distance_sq = global_position.distance_squared_to(target_horizontal_position)

		if distance_sq > 0.1:
			# Rotation
			var target_look_direction = direction_to_player
			target_look_direction.y = 0

			if target_look_direction.length_squared() > 0:
				var target_transform = Transform3D(Basis(), global_position).looking_at(global_position + target_look_direction, Vector3.UP)
				global_transform = global_transform.interpolate_with(target_transform, rotation_speed * delta)

			# Movement
			var move_direction = global_transform.basis.z.normalized() * -1.0
			velocity.x = move_direction.x * speed
			velocity.z = move_direction.z * speed
		else:
			# Stop when close
			velocity.x = move_toward(velocity.x, 0, speed)
			velocity.z = move_toward(velocity.z, 0, speed)
	else:
		# --- Idle Logic (Runs during the day) ---
		# Stop all horizontal movement during the day
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	# 3. Final Physics Step
	move_and_slide()
