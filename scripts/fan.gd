class_name Fan
extends Items

@onready var head: Node3D = $"../../Head"
@onready var camera: Camera3D = $"../../Head/Camera"

@onready var item_animation: AnimationPlayer = $Head/Camera/fan/AnimationPlayer
@onready var item_aim: RayCast3D = $Head/Camera/Aim
var fan_jumped: bool = false
var fan_cooldown_time: float = 0.1

var windslash = load("res://scenes/windslash.tscn")
var instance

func apply_shoot():
	if !item_animation.is_playing():
		item_animation.play("shoot")
		generate_windslash()
		if !is_on_floor():
			# parameter for the power of the backblast
			fan_blast(10)

func generate_windslash():
	instance = windslash.instantiate()
	instance.position = item_aim.global_position
	instance.transform.basis = item_aim.global_transform.basis
	get_parent().add_child(instance)
	
func fan_blast(blast_power: float):
	# for the backward motion
	velocity.x = -head.basis.x.z * (blast_power / 2)
	velocity.z = head.basis.x.x * (blast_power / 2)
	velocity.y = -camera.basis.y.z * blast_power
	fan_jumped = true
	get_tree().create_timer(fan_cooldown_time).timeout.connect(on_fan_blast_timeout)
	
func on_fan_blast_timeout():
	fan_jumped = false
