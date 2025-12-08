extends ProgressBar

@onready var health_bar: ProgressBar = $"."

var click : int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _input(event: InputEvent) -> void:
	
	# Testing for decreasing health bar
	#if event is InputEventMouseButton:
		#if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			#click += 1
			#print(click)
			#health_bar.value -= 10
		
		pass
