extends Node3D

const SPEED = 30.0

@onready var windslash: Node3D = $windslash
@onready var ray_cast_3d: RayCast3D = $RayCast3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += transform.basis * Vector3(0, 0, -SPEED) * delta
	
	if ray_cast_3d.is_colliding():
		windslash.visible = false
		await get_tree().create_timer(2.0).timeout
		queue_free()

func _on_timer_timeout() -> void:
	queue_free()
