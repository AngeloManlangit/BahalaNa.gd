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
var allow_input: bool = true

# for the jump buffer
var jump_buffer: bool = false
@export var jump_buffer_time: float = 0.2

# head and camera
@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera

# items
enum items { FIST, FAN, BOOMERANG, STICKY_HAND }
var equipped := items.FIST # default is fist

@onready var item_animation: AnimationPlayer
@onready var item_aim: RayCast3D = $Head/Camera/Aim
var aim_direction

# fan
@onready var fan: Node3D = $Head/Camera/fan
var fan_cooldown_time: float = 0.4
var windslash = load("res://scenes/windslash.tscn")
var instance

# sticky hand
@onready var sticky_hand: Area3D = $Head/Sticky_Hand
@onready var rope: Node3D = $Head/Rope
@onready var rope_model: CSGCylinder3D = $Head/Rope/Rope_Model
var did_stick: bool = false
const HAND_SPEED = 40.0

func _ready():
	capture_mouse()
	rope_model.visible = false
	fan.visible = false

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
	
	if allow_input:
		if direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			velocity.x = lerp(velocity.x, direction.x * SPEED, delta * weight)
			velocity.z = lerp(velocity.z, direction.z * SPEED, delta * weight)
	
	# using item

	if Input.is_action_just_pressed("shoot") and mouse_captured:
		match equipped:
			items.FIST:
				item_animation = $Head/Camera/fan/Fan_Animation
				punch()
			items.FAN:
				# Fan logic
				item_animation = $Head/Camera/fan/Fan_Animation
				if !item_animation.is_playing():
					item_animation.play("shoot")
					generate_windslash()
					if !is_on_floor():
						# parameter for the power of the backblast
						fan_blast(10)
			items.BOOMERANG:
				# Boomerang logic
				item_animation = $Head/Camera/fan/Fan_Animation
			items.STICKY_HAND:
				# sticky hand logic
				item_animation = $Head/Camera/fan/Fan_Animation
				shoot_hand(delta)
				sticky_pull()
				
		if !item_animation.is_playing():
			item_animation.play("shoot")
	
	move_and_slide()

# movement functions
func Jump() -> void:
	velocity.y = JUMP_VELOCITY 
	jump_available = false
	
func on_coyote_timeout():
	jump_available = false

func on_jump_buffer_timeout():
	jump_buffer = false

# mouse functions
func capture_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true

func release_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_captured = false

# item functions
# pickup
func pickup(picked_up_item: String):
	if picked_up_item == "FAN":
		equipped = items.FAN
		fan.visible = true

# fist
func punch():
	print("one punch")
	pass

# fan
func generate_windslash():
	instance = windslash.instantiate()
	instance.position = item_aim.global_position
	instance.transform.basis = item_aim.global_transform.basis
	get_parent().add_child(instance)
	
func fan_blast(blast_power: float):
	# for the backward motion
	velocity.x = -head.basis.x.z * (blast_power * 0.8)
	velocity.z = head.basis.x.x * (blast_power * 0.8)
	velocity.y = -camera.basis.y.z * blast_power
	allow_input = false
	get_tree().create_timer(fan_cooldown_time).timeout.connect(on_fan_blast_timeout)
	
func on_fan_blast_timeout():
	allow_input = true

# sticky hand
func shoot_hand(delta: float):
	if Input.is_action_just_pressed("shoot"):
		did_stick = false
		aim_direction = -camera.global_transform.basis.z
		
		var current_pos = sticky_hand.global_position
		if sticky_hand.get_parent():
			sticky_hand.get_parent().remove_child(sticky_hand)
		get_tree().root.add_child(sticky_hand)
		sticky_hand.global_position = current_pos
		rope_model.visible = true
	
	if Input.is_action_pressed("shoot"):
		if !did_stick:
			sticky_hand.global_position += aim_direction * delta * HAND_SPEED
		make_rope()
		
	if Input.is_action_just_released("shoot"):
		if sticky_hand.get_parent():
			sticky_hand.get_parent().remove_child(sticky_hand)
		head.add_child(sticky_hand)
		sticky_hand.position = Vector3(0.5, -0.5, -1)
		did_stick = false
		rope_model.visible = false
		
func on_hand_attached(_body):
	did_stick = true
	
func on_hand_free(_body):
	did_stick = false

func sticky_pull():
	if did_stick:
		var pull_force_modifier: float = pow((sticky_hand.global_position - head.global_position).normalized().length(), 0.5)
		var pull_force: Vector3 = pull_force_modifier * (sticky_hand.global_position - head.global_position).normalized()
		velocity.x += pull_force.x
		velocity.z += pull_force.z
		velocity.y += pull_force.y
	
func make_rope():
	var distance = head.global_position.distance_to(sticky_hand.global_position)
	rope.look_at(sticky_hand.global_position)
	rope_model.height = distance
	rope_model.position.z = -distance / 2.0
