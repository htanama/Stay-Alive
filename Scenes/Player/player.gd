extends CharacterBody3D

@onready var displayText = $CanvasLayer/DisplayText
@onready var arm_action : CSGBox3D = $Arm
@onready var camera_player: Camera3D = $CameraMount/CameraPlayer
@onready var raycast_3D: RayCast3D = $CameraMount/CameraPlayer/RayCast3D

const MAX_RAY_DISTANCE = 10.0

const SPEED = 5.0
const JUMP_VELOCITY = 5.0
var sprint_speed : float = 1.0

const MOUSE_SENSITIVITY = 0.002


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:     
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	_Sprint()
	_Attack()
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED * sprint_speed
		velocity.z = direction.z * SPEED * sprint_speed
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * sprint_speed)
		velocity.z = move_toward(velocity.z, 0, SPEED * sprint_speed)
		
		
	move_and_slide()

func _Sprint() -> void: 
	if Input.is_action_pressed("Sprint"):
		sprint_speed = 2.0
	else:
		sprint_speed = 1.0

func _Attack() -> void:
	# Always call force_raycast_update() to get the most accurate result right before the check
	raycast_3D.force_raycast_update()
	
	if Input.is_action_just_pressed("Attack") and raycast_3D.is_colliding():
		var space_state = get_world_3d().direct_space_state
		var viewport = get_viewport()
		var screen_center = viewport.get_size() / 2 
		
		
		# Calculate Ray Start and End
		var ray_origin = camera_player.project_ray_origin(screen_center)
		var ray_direction = camera_player.project_ray_normal(screen_center)
		var ray_end = ray_origin + (ray_direction * MAX_RAY_DISTANCE) * 1000
		
		# Perform the manual raycast
		var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
		query.collide_with_bodies = true;
		var result = space_state.intersect_ray(query)
		
		if result.is_empty():
			#Missed
			displayText.hide()
			print("Attack Missed.")
		else:
			#Hit result.collider
			var hit_object = result
			print(result)
			#print("RayCast hit: " + hit_object)
			#displayText.text = str(hit_object)
			displayText.show()
	else:
		# Hide the text if the attack button wasn't pressed
		displayText.hide()
