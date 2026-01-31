extends Node3D

@onready var start: Control = $Start

var started: bool = false
@onready var player: CharacterBody3D = $Player
@onready var pickup_area: Area3D = $Player/Pickup_Area

var time := 0.0
var is_stopped := false

@onready var loading: Control = $Loading

@onready var finish: Area3D = $Finish

@onready var time_label: Label = $Victory/Time_Label
@onready var victory: Control = $Victory

@onready var pickup_fan: Area3D = $Items/Pickup_Fan
@onready var pickup_fan_2: Area3D = $Items/Pickup_Fan2
@onready var pickup_fan_3: Area3D = $Items/Pickup_Fan3
@onready var pickup_fan_4: Area3D = $Items/Pickup_Fan4
@onready var pickup_boomerang: Area3D = $Items/Pickup_Boomerang
@onready var pickup_boomerang_2: Area3D = $Items/Pickup_Boomerang2
@onready var pickup_boomerang_3: Area3D = $Items/Pickup_Boomerang3
@onready var pickup_boomerang_4: Area3D = $Items/Pickup_Boomerang4
@onready var pickup_boomerang_5: Area3D = $Items/Pickup_Boomerang5
@onready var pickup_boomerang_6: Area3D = $Items/Pickup_Boomerang6
@onready var pickup_sticky_hand: Area3D = $Items/Pickup_StickyHand
@onready var pickup_sticky_hand_2: Area3D = $Items/Pickup_StickyHand2
@onready var pickup_sticky_hand_3: Area3D = $Items/Pickup_StickyHand3
@onready var pickup_sticky_hand_4: Area3D = $Items/Pickup_StickyHand4

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	victory.visible = false
	start.visible = true
	player.allow_input = false
	player.mouse_captured = false
	time = 0.0
	is_stopped = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !started and Input.is_action_just_pressed("jump"):
		player.mouse_captured = true
		started = true
		start.visible = false
		player.allow_input = true
	
	if started:
		if !is_stopped:
			time += delta
		
		if Input.is_action_just_pressed("restart"):
			loading.load_scene("res://scenes/level.tscn")
		elif Input.is_action_just_pressed("escape"):
			loading.load_scene("res://scenes/main_menu.tscn")
		
		if pickup_area.overlaps_area(finish):
			is_stopped = true
			victory.show()
			victory.play_victory(time)
		
		detect_items()
	
func detect_items():
	if pickup_fan.visible and pickup_area.overlaps_area(pickup_fan):
		player.pickup("FAN") # Function inside player script
		pickup_fan.visible = false
		pickup_fan.process_mode = Node.PROCESS_MODE_DISABLED
	elif pickup_fan_2.visible and pickup_area.overlaps_area(pickup_fan_2):
		player.pickup("FAN") # Function inside player script
		pickup_fan_2.visible = false
		pickup_fan_2.process_mode = Node.PROCESS_MODE_DISABLED
	elif pickup_fan_3.visible and pickup_area.overlaps_area(pickup_fan_3):
		player.pickup("FAN") # Function inside player script
		pickup_fan_3.visible = false
		pickup_fan_3.process_mode = Node.PROCESS_MODE_DISABLED
	elif pickup_fan_4.visible and pickup_area.overlaps_area(pickup_fan_4):
		player.pickup("FAN") # Function inside player script
		pickup_fan_4.visible = false
		pickup_fan_4.process_mode = Node.PROCESS_MODE_DISABLED
	elif pickup_boomerang.visible and pickup_area.overlaps_area(pickup_boomerang):
		player.pickup("BOOMERANG")
		pickup_boomerang.visible = false
		pickup_boomerang.process_mode = Node.PROCESS_MODE_DISABLED
	elif pickup_boomerang_2.visible and pickup_area.overlaps_area(pickup_boomerang_2):
		player.pickup("BOOMERANG")
		pickup_boomerang_2.visible = false
		pickup_boomerang_2.process_mode = Node.PROCESS_MODE_DISABLED
	elif pickup_boomerang_3.visible and pickup_area.overlaps_area(pickup_boomerang_3):
		player.pickup("BOOMERANG")
		pickup_boomerang_3.visible = false
		pickup_boomerang_3.process_mode = Node.PROCESS_MODE_DISABLED
	elif pickup_boomerang_4.visible and pickup_area.overlaps_area(pickup_boomerang_4):
		player.pickup("BOOMERANG")
		pickup_boomerang_4.visible = false
		pickup_boomerang_4.process_mode = Node.PROCESS_MODE_DISABLED
	elif pickup_sticky_hand.visible and pickup_area.overlaps_area(pickup_sticky_hand):
		player.pickup("STICKY_HAND")
		pickup_sticky_hand.visible = false
		pickup_sticky_hand.process_mode = Node.PROCESS_MODE_DISABLED
	elif pickup_sticky_hand_2.visible and pickup_area.overlaps_area(pickup_sticky_hand_2):
		player.pickup("STICKY_HAND")
		pickup_sticky_hand_2.visible = false
		pickup_sticky_hand_2.process_mode = Node.PROCESS_MODE_DISABLED
	elif pickup_sticky_hand_3.visible and pickup_area.overlaps_area(pickup_sticky_hand_3):
		player.pickup("STICKY_HAND")
		pickup_sticky_hand_3.visible = false
		pickup_sticky_hand_3.process_mode = Node.PROCESS_MODE_DISABLED
	elif pickup_sticky_hand_4.visible and pickup_area.overlaps_area(pickup_sticky_hand_4):
		player.pickup("STICKY_HAND")
		pickup_sticky_hand_4.visible = false
		pickup_sticky_hand_4.process_mode = Node.PROCESS_MODE_DISABLED
