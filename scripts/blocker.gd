extends CharacterBody3D

@export var animationPlayer : AnimationPlayer
enum States {attacks, idle, die}

var state = States.idle
var hp = 15
var speed = 2
var target = null
var look = false
var gravity = 9.8
var active = true

func _process(delta: float) -> void:
	if hp <= 0:
		state = States.die 
		
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y = gravity * delta
	if state == States.idle and active == true:
		if look == true:
			look_at(Vector3(target.global_position.x, global_position.y, target.global_position.z), Vector3.UP, true)
			
		velocity = Vector3.ZERO
		
	
	elif state == States.attacks and active == true:
		velocity = Vector3.ZERO
		look_at(Vector3(target.global_position.x, global_position.y, target.global_position.z), Vector3.UP, true)
		
	elif state == States.die and active == true:
		velocity = Vector3.ZERO
		active = false
		

func attack():
	if target:
		var knockback_dir = (target.global_position - global_position).normalized()
		var strength = 10
		var lift = 2.0 
		target.velocity = knockback_dir * strength
		target.velocity.y = lift
		target.velocity = knockback_dir * strength
		target.allow_input = false
		await get_tree().create_timer(0.5).timeout
		target.allow_input  = true
	
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
