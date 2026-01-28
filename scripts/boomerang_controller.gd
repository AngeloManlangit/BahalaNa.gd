extends Node

@export var equipped_boomerang: Node3D
@onready var player: CharacterBody3D = get_parent()
@export var item_aim: RayCast3D
@onready var throw_boomerang: Node3D = $"Throw_Boomerang"

enum BoomerState { INACTIVE, THROW, HALT, RETURN }
var state

var thrown: bool
var returned: bool

var halt_timer: Timer

var direction
var speed: float = 0
@export var ACCELERATION: float = 120.0
@export var MAX_SPEED: float = 40.0

func _ready():
	thrown = false
	returned = false
	throw_boomerang.visible = false
	state = BoomerState.INACTIVE
	
	# halt timer
	halt_timer = Timer.new()
	halt_timer.one_shot = true
	halt_timer.wait_time = 1.5
	halt_timer.timeout.connect(on_boomerang_timeout)
	add_child(halt_timer)

func begin_throw():
	equipped_boomerang.visible = false
	thrown = true
	returned = false
	speed = MAX_SPEED
	state = BoomerState.THROW
	throw_boomerang.begin_throw()
	throw_boomerang.position = item_aim.global_position - Vector3(0, 0.2, 0)
	direction = item_aim.global_transform.basis
	
func throw(delta: float):	
	match state:
		BoomerState.THROW:
			print("Throw: " + str(speed))
			speed -= ACCELERATION * delta
			print(str(speed))
			throw_boomerang.position += direction * Vector3(0, 0, -speed) * delta
			print(str(throw_boomerang.position))
			
			if speed <= 0: 
				print("Halt from Speed")
				enter_halt_state()
			elif throw_boomerang.shape_cast.is_colliding():
				var temp = throw_boomerang.shape_cast.get_collider(0)
				if temp:
					print("Hitted: ", temp.name)
				
				print("Halt from hit")
				enter_halt_state()
				
		BoomerState.HALT:
			print("Halt")
				
		BoomerState.RETURN:
			print("Return")
			direction = throw_boomerang.global_position.direction_to(player.global_position)
			speed += ACCELERATION * delta
			throw_boomerang.position += direction * speed * delta
			
			if throw_boomerang.global_position.distance_to(player.global_position) <= 1:
				speed = 0
				throw_boomerang.visible = false
				state = BoomerState.INACTIVE
				returned = true
				thrown = false

func enter_halt_state():
	state = BoomerState.HALT
	throw_boomerang.jumpable()
	halt_timer.start()

func on_boomerang_timeout():
	throw_boomerang.unjumpable()
	state = BoomerState.RETURN
	
func hide_self():
	equipped_boomerang.visible = false
	throw_boomerang.unjumpable()
