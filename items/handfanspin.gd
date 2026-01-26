extends Area3D

@export var spin_speed : float = 1.0
@export var hover_speed : float = 2.0
@export var hover_height : float = 0.2

# We track time to create the sine wave
var time_passed : float = 0.0
# We store the initial position so we can hover relative to it
@onready var initial_y = $Visuals.position.y

func _process(delta):
	# 1. Accumulate time
	time_passed += delta
	
	# 2. Make the Visuals node spin
	# We rotate just the mesh, not the collision box!
	$Visuals.rotate_y(spin_speed * delta)
	
	# 3. Make the Visuals node float
	# sin() creates a wave between -1 and 1. 
	var new_y = initial_y + (sin(time_passed * hover_speed) * hover_height)
	$Visuals.position.y = new_y
