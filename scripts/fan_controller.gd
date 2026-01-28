extends Node

@export var equipped_fan: Node3D
var fan_cooldown_time: float = 0.5
var windslash = load("res://scenes/windslash.tscn")
var instance

@onready var player: CharacterBody3D = get_parent()
@export var item_aim: RayCast3D

@onready var head: Node3D = $"../Head"
@onready var camera: Camera3D = $"../Head/Camera"

func generate_windslash():
	instance = windslash.instantiate()
	instance.position = item_aim.global_position - Vector3(0, 0.3, 0)
	instance.transform.basis = item_aim.global_transform.basis
	player.get_parent().add_child(instance)
	
func fan_blast(blast_power: float):
	# for the backward motion
	player.velocity.x = -head.basis.x.z * (blast_power * 0.8)
	player.velocity.z = head.basis.x.x * (blast_power * 0.8)
	player.velocity.y = -camera.basis.y.z * blast_power
	player.allow_input = false
	get_tree().create_timer(fan_cooldown_time).timeout.connect(on_fan_blast_timeout)
	
func on_fan_blast_timeout():
	player.allow_input = true
	
func hide_self():
	equipped_fan.visible = false
