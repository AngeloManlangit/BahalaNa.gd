extends Node

@export var equipped_boomerang: Node3D
@onready var player: CharacterBody3D = get_parent()
@export var item_aim: RayCast3D
@onready var throw_boomerang: Node3D = $"Throw_Boomerang"

enum BoomerState { INACTIVE, THROW, HALT, RETURN }
var state

var thrown: bool
var returned: bool

var direction
var speed: float = 0
@export var ACCELERATION: float = 100.0
@export var MAX_SPEED: float = 30.0

func _ready():
	thrown = false
	returned = false
	throw_boomerang.visible = false
	state = BoomerState.INACTIVE

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
			
			if speed <= 0 || throw_boomerang.ray_cast.is_colliding():
				state = BoomerState.HALT
				
		BoomerState.HALT:
			print("Halt")
			throw_boomerang.jumpable()
			throw_boomerang.get_tree().create_timer(2.0).timeout.connect(on_boomerang_timeout)
			
		BoomerState.RETURN:
			print("Return")
			direction = throw_boomerang.global_position.direction_to(player.global_position)
			speed += ACCELERATION * delta
			throw_boomerang.position += direction * speed * delta
			
			if throw_boomerang.global_position.distance_to(player.global_position) <= 1:
				speed = 0
				throw_boomerang.visible = false
				equipped_boomerang.visible = true
				state = BoomerState.INACTIVE
				returned = true
				thrown = false
							
func on_boomerang_timeout():
	throw_boomerang.unjumpable()
	state = BoomerState.RETURN
	
func hide_self():
	equipped_boomerang.visible = false
	throw_boomerang.unjumpable()
