extends Node

@onready var player: CharacterBody3D = %Player
@onready var pickup_area: Area3D = $"../Player/Pickup_Area"
@onready var fan: StaticBody3D = $"../Fan"

func _process(_delta: float) -> void:
	if fan and fan.visible and pickup_area.overlaps_body(fan):
		player.pickup("FAN") # Function inside player script
		fan.hide()
		fan.process_mode = Node.PROCESS_MODE_DISABLED
