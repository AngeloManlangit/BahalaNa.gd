extends Node

@onready var player: CharacterBody3D = %Player
@onready var pickup_area: Area3D = $"%Player/Pickup_Area"
@onready var pickup_fan: Area3D = $"../Pickup_Fan"
@onready var pickup_boomerang: Area3D = $"../Pickup_Boomerang"
@onready var pickup_sticky_hand: Area3D = $"../Pickup_StickyHand"

func _process(_delta: float) -> void:
	if pickup_fan.visible and pickup_area.overlaps_area(pickup_fan):
		player.pickup("FAN") # Function inside player script
	elif pickup_boomerang.visible and pickup_area.overlaps_area(pickup_boomerang):
		player.pickup("BOOMERANG")
	elif pickup_sticky_hand.visible and pickup_area.overlaps_area(pickup_sticky_hand):
		player.pickup("STICKY_HAND")
