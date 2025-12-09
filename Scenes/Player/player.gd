extends CharacterBody3D

var raycast_test = preload("res://Scenes/Objects/bullet.tscn")

@onready var displayText = $CanvasLayer/DisplayText
@onready var arm_action : CSGBox3D = $Arm
@onready var camera_player: Camera3D = $CameraMount/CameraPlayer
@onready var raycast_3D: RayCast3D = $CameraMount/CameraPlayer/RayCast3D

const MAX_RAY_DISTANCE = 100

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
		var ray_end = ray_origin + (ray_direction * MAX_RAY_DISTANCE)
		
		# Perform the manual raycast
		var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
		query.collide_with_bodies = true;
		var result = space_state.intersect_ray(query)
		
		if result:
			var hit_object = result.get("collider")
			var enemy_root: Node = null
			
			# assign hit_object to current_node to check if current_node is in the gropu enemy later
			var current_node: Node = hit_object # Start climbing from the hit object
			
			#check if current_node is in the enemy group 
			while current_node != null:
				if current_node.is_in_group("enemy"):
					print("current_node is in enemy group")
					enemy_root = current_node
					break
				# Stop if we hit the root of the whole scene tree
				if current_node == get_tree().root:
					break
				
				current_node = current_node.get_parent()
				
			if enemy_root:
				enemy_root.queue_free()
				print("Enemy HIT and removed successfully!")
			
			#Hit result.collider
			_test_raycast(result.get("position"))
			
			#print("RayCast hit: " + hit_object)
			#displayText.text = str(hit_object)
			displayText.show()
		
		
	else:
		# Hide the text if the attack button wasn't pressed
		displayText.hide()

func _test_raycast(position: Vector3) -> void:
	var instance = raycast_test.instantiate()
	get_tree().root.add_child(instance)
	instance.global_position = position
	await get_tree().create_timer(3).timeout
	instance.queue_free()
