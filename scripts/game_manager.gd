extends Node

@onready var player: CharacterBody3D = %Player
@onready var pickup_area: Area3D = $"../Player/Pickup_Area"
@onready var pickup_fan: StaticBody3D = $"../Fan"

func _process(_delta: float) -> void:
	if pickup_fan and pickup_fan.visible and pickup_area.overlaps_body(pickup_fan):
		player.pickup("FAN") # Function inside player script
		pickup_fan.hide()
		pickup_fan.process_mode = Node.PROCESS_MODE_DISABLED
