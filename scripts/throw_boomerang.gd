extends Node3D

@onready var animation: AnimationPlayer = $boomerang/Animation
@onready var csg_box_3d: CSGBox3D = $CSGBox3D
@export var shape_cast: ShapeCast3D
@export var timer: Timer
var target = null

func begin_throw():
	animation.play("spin")
	visible = true
	unjumpable()
	
func jumpable():
	csg_box_3d.use_collision = true

func unjumpable():
	csg_box_3d.use_collision = false

func _on_attack_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("enemy"):
		target = body
		target.take_damage()	
