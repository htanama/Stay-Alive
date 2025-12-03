extends CharacterBody3D

@export var speed: float = 1.0
@export var rotation_speed: float = 5.0

# 1. Define the path to the player node
# Change "Player" to the actual name of your player node in the scene tree.
const PLAYER_PATH = "../Player" 

var player: Node3D = null

# Get the gravity from the project settings
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready() -> void:
	# Attempt to find the player node
	player = get_node_or_null(PLAYER_PATH)
	if not player:
		print("ERROR: Player node not found at path: ", PLAYER_PATH)
		set_process(false) # Disable script if player isn't found

func _physics_process(delta: float) -> void:
	if not player:
		return

	# --- 1. Apply Gravity (for 3D stability) ---
	if not is_on_floor():
		velocity.y -= gravity * delta

	# --- 2. Calculate Direction to Player ---
	var direction_to_player = (player.global_position - global_position).normalized()
	
	# Check the horizontal distance (ignore height difference for chasing)
	var target_horizontal_position = Vector3(player.global_position.x, global_position.y, player.global_position.z)
	var distance_sq = global_position.distance_squared_to(target_horizontal_position)

	if distance_sq > 0.1: # Only move if we aren't right on top of the player

		# --- 3. Rotation (Turning to face the player) ---
		# Calculate the rotation needed to look at the target position
		var target_look_direction = direction_to_player
		target_look_direction.y = 0 # Keep rotation flat on the XZ plane

		if target_look_direction.length_squared() > 0:
			# Create a target transform where the Z-axis points towards the player
			var target_transform = Transform3D(Basis(), global_position).looking_at(global_position + target_look_direction, Vector3.UP)
			
			# Interpolate the current rotation to the target rotation for smooth turning
			global_transform = global_transform.interpolate_with(target_transform, rotation_speed * delta)

		# --- 4. Movement (Chasing) ---
		# Move forward in the direction the enemy is currently facing
		var move_direction = global_transform.basis.z.normalized() * -1.0
		
		# Apply movement speed, but preserve gravity's effect on Y velocity
		velocity.x = move_direction.x * speed
		velocity.z = move_direction.z * speed
		
	else:
		# Stop movement when close
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
		
	# --- 5. Final Physics Step ---
	move_and_slide()
