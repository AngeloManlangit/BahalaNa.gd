extends Control

@onready var loading: Control = $Loading

@onready var boomerang: Node3D = $SubViewportContainer/SubViewport/boomerang
@onready var handfan: Node3D = $SubViewportContainer/SubViewport/handfan
@onready var sticky_hand: Node3D = $"SubViewportContainer/SubViewport/sticky hand"

var rng = RandomNumberGenerator.new()

var my_stylebox = load("res://scenes/main_menu.tscn::StyleBoxFlat_l6cm7") as StyleBoxFlat

func _ready():
	rng.randomize()
	
	boomerang.visible = false
	handfan.visible = false
	sticky_hand.visible = false
	
	var my_random_number = rng.randi_range(1, 3)
	
	match my_random_number:
		1:
			boomerang.visible = true
			my_stylebox.bg_color = Color.from_rgba8(60, 105, 139, 255)
		2:
			handfan.visible = true
			my_stylebox.bg_color = Color.from_rgba8(175, 25, 0, 255)
		3:
			sticky_hand.visible = true
			my_stylebox.bg_color = Color.from_rgba8(58, 121, 42, 255)

func _on_start_pressed() -> void:
	print("Start Pressed")
	loading.load_scene("res://scenes/level.tscn")

func _on_options_pressed() -> void:
	loading.load_scene("res://scenes/level_enemy.tscn")

func _on_exit_pressed() -> void:
	print("Exit Pressed")
	get_tree().quit()
