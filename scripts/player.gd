extends CharacterBody3D

# movement variables
const SPEED = 7.0
const JUMP_VELOCITY = 6.0
const MOUSE_SENSITIVITY = 0.005
const weight = 7.0
var mouse_captured: bool

# for the coyote time
@export var coyote_time: float = 0.2
@onready var coyote_timer: Timer = $Coyote_Timer
var jump_available: bool = true

# for the jump buffer
var jump_buffer: bool = false
@export var jump_buffer_time: float = 0.2

# head and camera
@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera

# items
@onready var item_animation: AnimationPlayer = $Head/Camera/fan/AnimationPlayer
@onready var item_aim: RayCast3D = $Head/Camera/RayCast3D

var windslash = load("res://scenes/windslash.tscn")
var instance

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
		
		# for coyote time when jumping
		if jump_available:
			if coyote_timer.is_stopped():
				coyote_timer.start(coyote_time)
		
		velocity += get_gravity() * delta
	else:
		jump_available = true
		coyote_timer.stop()
		
		if jump_buffer:
			Jump()
			jump_buffer = false

	# Handle jump.
	if Input.is_action_just_pressed("jump"):
		if jump_available:
			Jump()
		else:
			jump_buffer = true
			get_tree().create_timer(jump_buffer_time).timeout.connect(on_jump_buffer_timeout)

	# Get the input direction and handle the movement/deceleration.
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction := (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = lerp(velocity.x, direction.x * SPEED, delta * weight)
		velocity.z = lerp(velocity.z, direction.z * SPEED, delta * weight)
	
	# using item
	if Input.is_action_pressed("shoot") and mouse_captured:
		if !item_animation.is_playing():
			print("Shooting")
			item_animation.play("shoot")
			instance = windslash.instantiate()
			instance.position = item_aim.global_position
			instance.transform.basis = item_aim.global_transform.basis
			get_parent().add_child(instance)
	
	move_and_slide()

func Jump() -> void:
	velocity.y = JUMP_VELOCITY 
	jump_available = false
	
func on_coyote_timeout():
	jump_available = false

func on_jump_buffer_timeout():
	jump_buffer = false

func capture_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true

func release_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_captured = false
