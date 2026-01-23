extends CharacterBody3D

const SPEED = 10.0
const JUMP_VELOCITY = 6.0
const MOUSE_SENSITIVITY = 0.005

const weight = 7.0

var mouse_captured: bool

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera

func _ready():
	capture_mouse()

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		capture_mouse()
	if Input.is_key_pressed(KEY_ESCAPE):
		release_mouse()
	
	if mouse_captured and event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		camera.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-85), deg_to_rad(85))

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction := (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	# change between these two for testing (uncomment one and comment the other)
	# no_intertia(direction, delta)
	with_intertia(direction, delta)
	
	move_and_slide()
	
func no_intertia(direction, delta: float):
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = lerp(velocity.x, direction.x * SPEED, delta * weight)
		velocity.z = lerp(velocity.z, direction.z * SPEED, delta * weight)
		
func with_intertia(direction, delta: float):
	if is_on_floor():
		if direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			velocity.x = lerp(velocity.x, direction.x * SPEED, delta * weight)
			velocity.z = lerp(velocity.z, direction.z * SPEED, delta * weight)
	else:
		# for inertia mid-air
		const air_weight: float = 6.0
		velocity.x = lerp(velocity.x, direction.x * SPEED, delta * air_weight)
		velocity.z = lerp(velocity.z, direction.z * SPEED, delta * air_weight)

func capture_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true

func release_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_captured = false
