extends DirectionalLight3D

## --- Configuration ---

@export_range(0.01, 10.0, 0.01) var time_scale: float = 1.0 
# Speed of the cycle. 1.0 is standard speed. Higher is faster.
@export var day_duration_seconds: float = 120.0 
# Total duration of one full cycle (day + night) in real-world seconds.

# The current time in the cycle, ranging from 0.0 (midnight) to 1.0 (midnight next day)
var time_of_day: float = 0.25 # Start at 0.25 (Sunrise)

## --- Light and Color Settings ---

# Day/Sun Color and Intensity
const DAY_COLOR = Color(1.0, 0.95, 0.85) # Warm Yellow/White
const DAY_INTENSITY = 1.0

# Night/Moon Color and Intensity
const NIGHT_COLOR = Color(0.2, 0.3, 0.5) # Cool Blue
const NIGHT_INTENSITY = 0.1

# Dawn/Dusk Color
const DAWN_DUSK_COLOR = Color(0.9, 0.5, 0.3) # Orange/Red

## --- Reference to Environment Node ---

# @onready var world_environment = $"/root/YourSceneName/WorldEnvironment" 
# Uncomment and set the correct path if you need to control the environment node.


func _process(delta: float) -> void:
	# 1. Update the time
	var cycle_speed = (1.0 / day_duration_seconds) * time_scale
	time_of_day += delta * cycle_speed
	
	# Wrap time_of_day back to 0.0 after a full cycle (1.0)
	if time_of_day >= 1.0:
		time_of_day -= 1.0
		
	# 2. Update Light Rotation (Sun/Moon Position)
	# The light's rotation determines its position in the sky.
	# We rotate around the X-axis (Pitch) based on time_of_day.
	# 0.25 is sunrise, 0.5 is noon, 0.75 is sunset, 0.0/1.0 is midnight.
	var angle = time_of_day * 360.0
	rotation_degrees.x = angle
	
	# 3. Update Light Properties (Color and Intensity)
	update_light_properties()
	
func update_light_properties() -> void:
	# The blend_factor is used to interpolate between the day and night settings.
	# It peaks near 0.5 (noon) and is low near 0.0/1.0 (midnight).
	
	var blend_factor: float
	var intensity: float
	var light_color: Color
	
	# Calculate factor based on distance to 0.5 (noon) vs 0.0/1.0 (midnight).
	# This smooths the transition near dawn/dusk.
	var cycle_phase = abs(time_of_day - 0.5)
	
	# Use a smooth step function for transition, peaking at 0.5 (noon)
	blend_factor = 1.0 - smoothstep(0.0, 0.5, cycle_phase)
	
	# Interpolate Intensity: Night to Day
	intensity = lerp(NIGHT_INTENSITY, DAY_INTENSITY, blend_factor)
	
	# Interpolate Color: Night to Day (using Dawn/Dusk color near transitions)
	if time_of_day < 0.25 || time_of_day > 0.75: # Night/Dawn/Dusk transition time
		light_color = lerp(NIGHT_COLOR, DAWN_DUSK_COLOR, min(blend_factor * 2.0, 1.0))
	else: # Day time
		light_color = lerp(DAWN_DUSK_COLOR, DAY_COLOR, min((blend_factor - 0.5) * 2.0, 1.0))
		
	# Apply the calculated properties to the DirectionalLight3D
	light_color = light_color
	light_energy = intensity
	
	# --- Optional: Update Environment Fog/Sky ---
	# if world_environment:
	#     # Example: Control sky color or fog density based on blend_factor
	#     var fog_density = lerp(0.05, 0.0, blend_factor) 
	#     world_environment.environment.volumetric_fog_density = fog_density
# --- Add this function to your DayNightCycle.gd ---
func get_time_of_day() -> float:
		return time_of_day
