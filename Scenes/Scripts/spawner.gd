extends CSGBox3D

# Preload the Zombie scene for efficient instantiation
const ZOMBIE_SCENE = preload("res://Scenes/Zombies/zombies.tscn")
const SPAWN_POINT: Vector3 = Vector3(18.0, 0.5, -0.3) # location of the Spawner
const SPAWN_DELAY: float = 3.0
const MAX_ZOMBIES : int = 100
var current_zombies = 0
var enemy_parent_node: Node = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	enemy_parent_node = get_tree().root.get_node("Level1")
	
	if enemy_parent_node:
		call_deferred("spawn_wave")
		

func spawn_wave():
	while current_zombies < MAX_ZOMBIES:
		await get_tree().create_timer(SPAWN_DELAY).timeout
		spawn_enemy()
		current_zombies += 1

func spawn_enemy():
	#await get_tree().create_timer(SPAWN_DELAY).timeout
	var enemy_instance = ZOMBIE_SCENE.instantiate()
	enemy_parent_node.call_deferred("add_child", enemy_instance)
	
	# This pauses execution until the enemy is fully in the scene tree.
	await enemy_instance.tree_entered
	enemy_instance.global_position = SPAWN_POINT
	
	#get_tree().root.add_child(enemy_instance)
	#get_tree().root.call_deferred("add_child", enemy_instance)
	#get_tree().root.get_node("Level1").call_deferred("add_child", enemy_instance)
	
