extends CSGBox3D

# Preload the Zombie scene for efficient instantiation
const ZOMBIE_SCENE = preload("res://Scenes/Zombies/zombies.tscn")
const SPAWN_POINT: Vector3 = Vector3(18.0, 0.5, -0.3) # location of the Spawner
const SPAWN_DELAY: float = 20.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	call_deferred("spawn_enemy")


func spawn_enemy():
	await get_tree().create_timer(SPAWN_DELAY).timeout
	
	var enemy_instance = ZOMBIE_SCENE.instantiate()
	
	#get_tree().root.add_child(enemy_instance)
	#get_tree().root.call_deferred("add_child", enemy_instance)
	get_tree().root.get_node("Level1").call_deferred("add_child", enemy_instance)
	
	# Waits for the moment the node is fully added and processed.	
	await enemy_instance.tree_entered
	
	enemy_instance.global_position = SPAWN_POINT	
	
