extends CharacterBody3D

# player variables
var health_points = 2 # default: 2
var item_uses = 5 # default: 5

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
@onready var fan_controller: Node = $FanController

# boomerang
@onready var boomerang_controller: Node = $BoomerangController

# sticky hand
@onready var sh_controller: Node = $StickyHandController

# UI
@onready var uses_label: Label = $Head/Camera/Temp_UI/Uses
@onready var cooldown_label: Label = $Head/Camera/Temp_UI/Cooldown

func _ready():
	capture_mouse()
	fan_controller.equipped_fan.visible = false
	boomerang_controller.equipped_boomerang.visible = false
	sh_controller.rope.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		capture_mouse()
	if Input.is_key_pressed(KEY_ESCAPE):
		release_mouse()
		
	if mouse_captured and event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		camera.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-85), deg_to_rad(85))
		
func _process(delta: float) -> void:
	uses_label.text = "Uses: " + str(item_uses)
	

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
	if mouse_captured:
		match equipped:
			items.FIST:
				item_animation = $Head/Camera/equipped_fan/Animation
				if Input.is_action_just_pressed("shoot"):
					punch()
			items.FAN:
				# Fan logic
				fan_controller.equipped_fan.visible = true
				item_animation = $Head/Camera/equipped_fan/Animation
				if Input.is_action_pressed("shoot"):
					if !item_animation.is_playing():
						item_animation.play("shoot")
						item_uses -= 1
						fan_controller.generate_windslash()
						if !is_on_floor():
							# parameter for the power of the backblast
							fan_controller.fan_blast(10)
						
						if item_uses == 0:
							fan_controller.equipped_fan.visible = false
							equipped = items.FIST
			items.BOOMERANG:
				# Boomerang logic
				boomerang_controller.equipped_boomerang.visible = true
				if !boomerang_controller.thrown:
					if Input.is_action_just_pressed("shoot"):
						item_uses -= 1
						boomerang_controller.begin_throw()
				
				if item_uses == 0 && boomerang_controller.returned:
					boomerang_controller.equipped_boomerang.visible = false
					equipped = items.FIST
			items.STICKY_HAND:
				# sticky hand logic
				if Input.is_action_just_pressed("shoot"):
					allow_input = false
					sh_controller.launch_hand()
				
				if Input.is_action_just_released("shoot"):
					item_uses -= 1
					sh_controller.retract_hand()
	
				if sh_controller.launched:
					sh_controller.handle_grapple(delta)
					
				if item_uses == 0:
					equipped = items.FIST
		
				sh_controller.update_rope()
	
	if boomerang_controller.thrown and !boomerang_controller.returned:
		boomerang_controller.equipped_boomerang.visible = false
		boomerang_controller.throw(delta)
		
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
	match equipped:
		items.FAN:
			fan_controller.hide_self()
		items.BOOMERANG:
			boomerang_controller.hide_self()
		items.STICKY_HAND:
			sh_controller.hide_self()
	
	if picked_up_item == "FAN":
		equipped = items.FAN
		item_uses = 5
	elif picked_up_item == "BOOMERANG":
		equipped = items.BOOMERANG
		item_uses = 3
	elif picked_up_item == "STICKY_HAND":
		equipped = items.STICKY_HAND
		item_uses = 2

# fist
func punch():
	print("one punch")
	pass
