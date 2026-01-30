extends Control

@onready var video_stream_player: VideoStreamPlayer = $VideoStreamPlayer
@onready var loading: Control = $Loading

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	video_stream_player.hide()
	pass # Replace with function body.

func _on_start_pressed() -> void:
	print("Start Pressed")
	loading.load_scene("res://scenes/game.tscn")

func _on_options_pressed() -> void:
	print("Options Pressed")
	video_stream_player.show()
	video_stream_player.play()

func _on_exit_pressed() -> void:
	print("Exit Pressed")
	get_tree().quit()
