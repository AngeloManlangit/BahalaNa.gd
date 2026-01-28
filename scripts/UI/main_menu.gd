extends Control

@onready var video_stream_player: VideoStreamPlayer = $VideoStreamPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	video_stream_player.hide()
	pass # Replace with function body.

func _on_start_pressed() -> void:
	print("Start Pressed")
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_options_pressed() -> void:
	print("Options Pressed")
	video_stream_player.show()
	video_stream_player.play()

func _on_exit_pressed() -> void:
	print("Exit Pressed")
	get_tree().quit()
