extends Node3D

@onready var animation: AnimationPlayer = $boomerang/Animation
@onready var csg_box_3d: CSGBox3D = $CSGBox3D
@export var ray_cast: RayCast3D
@export var timer: Timer

func begin_throw():
	animation.play("spin")
	visible = true
	unjumpable()
	
func jumpable():
	csg_box_3d.use_collision = true

func unjumpable():
	csg_box_3d.use_collision = false
