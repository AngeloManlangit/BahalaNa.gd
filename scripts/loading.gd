extends Control

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $SubViewportContainer/SubViewport/Loading_Run/AnimationPlayer
@onready var progress_bar: ProgressBar = $ProgressBar
var next_scene_path: String
var progress: Array[float] = []

func _ready() -> void:
	visible = false

func load_scene(next_scene: String):
	visible = true
	animated_sprite_2d.play("default")
	animation_player.play("mixamo_com")
	next_scene_path = next_scene
	ResourceLoader.load_threaded_request(next_scene_path)

func _process(delta: float) -> void:
	var status = ResourceLoader.load_threaded_get_status(next_scene_path, progress)
	
	match status:
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			var pct = progress[0] * 100
			progress_bar.value = pct
		ResourceLoader.THREAD_LOAD_LOADED:
			var scene = ResourceLoader.load_threaded_get(next_scene_path)
			get_tree().change_scene_to_packed(scene)
			visible = false
