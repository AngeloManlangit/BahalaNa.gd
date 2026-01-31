extends CharacterBody3D

@export var animationPlayer : AnimationPlayer
@onready var ray = $Shootpivot/RayCast3D
@onready var timer = $Timer
@onready var shoot_pivot = $Shootpivot
@onready var laser_mesh = $Shootpivot/RayCast3D/MeshInstance3D
enum States {attacks, idle, die}

var state = States.idle
var speed = 2
var target = null
var look = false
var gravity = 9.8
var active = true
var is_shooting = false
		
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y = gravity * delta
	if state == States.idle and active == true:
		animationPlayer.play("idle/mixamo_com")
		if look == true:
			look_at(Vector3(target.global_position.x, global_position.y, target.global_position.z), Vector3.UP, true)
		velocity = Vector3.ZERO
		
	
	elif state == States.attacks and active == true:
		if target and shoot_pivot:
			
			var aim_target = target.global_position + Vector3(0, 1.5, 0) #so the raycast is directed towards the player's face
			shoot_pivot.look_at(aim_target, Vector3.UP, true)
			look_at(Vector3(target.global_position.x, global_position.y, target.global_position.z), Vector3.UP, true)
			var collider = ray.get_collider()
			
			if collider == target and not is_shooting: #raycast is blocked
				handle_shooting_cycle()
				
		velocity = Vector3.ZERO
		look_at(Vector3(target.global_position.x, global_position.y, target.global_position.z), Vector3.UP, true)
		
	elif state == States.die and active == true:
		velocity = Vector3.ZERO
		animationPlayer.play("shutdown/mixamo_com")
		active = false
		
func handle_shooting_cycle():
	is_shooting = true  # LOCK: No more shots can start until this is false
	laser_mesh.visible = true
	timer.start(0.75)
	animationPlayer.play("attack/mixamo_com")
	await timer.timeout
	
	# RE-CHECK: Make sure the player didn't move behind a wall during the 0.5s
	if ray.get_collider() == target:
		attack()
	laser_mesh.visible = false
	# COOLDOWN: Wait 1 second before allowed to shoot again
	timer.start(1.0)
	await timer.timeout
	is_shooting = false # UNLOCK: Now the AI can look for a new shot
func attack():
	if target.has_method("take_damage"):
		target.take_damage()
	print(target.health_points )
func take_damage():
	print("hit")
	state = States.die
func _on_attack_area_body_entered(body: Node3D):
	if body.is_in_group("player"):
		state = States.attacks
		target = body
	
		
		


func _on_attack_area_body_exited(body: Node3D):
	if body.is_in_group("player"):
		state = States.idle
		
	
	


func _on_detect_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		
		look = true
		target = body
	


func _on_detect_area_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		look = false
