extends Node

@export var equipped_stickyhand: Node3D

@export var ray: RayCast3D
@export var rope: Node3D

@onready var player: CharacterBody3D = get_parent()


var force := Vector3.ZERO
const PULL_FORCE_STRENGTH: float = 100.0
var target: Vector3
var launched: bool = false
	
func launch_hand():	
	if ray.is_colliding():
		equipped_stickyhand.visible = false
		target = ray.get_collision_point()
		launched = true

func retract_hand():
	equipped_stickyhand.visible = true
	player.allow_input = true
	launched = false
	
func handle_grapple(delta: float):
	var target_direction = player.global_position.direction_to(target).normalized()
	var target_distance = player.global_position.distance_to(target)
	
	if target_distance > 0:
		force = target_direction * PULL_FORCE_STRENGTH
		
	player.velocity.x += force.x * delta
	player.velocity.z += force.z * delta
	# so that the player doesn't go so high
	if player.velocity.y < 15.0:
		player.velocity.y += force.y * delta

func update_rope():
	if !launched:
		rope.visible = false
		return
		
	rope.visible = true
	
	var distance = player.global_position.distance_to(target)
	
	rope.look_at(target)
	rope.scale = Vector3(1, 1, distance)
	
func hide_self():
	rope.visible = false
	retract_hand()
