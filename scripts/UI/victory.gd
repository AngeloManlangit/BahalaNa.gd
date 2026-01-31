extends Control

@onready var animation_player: AnimationPlayer = $"SubViewportContainer/SubViewport/Swing To Land Animation/AnimationPlayer"
@onready var time_label: Label = $Time_Label
@onready var label_3: Label = $Label3
@onready var animation: AnimationPlayer = $Label3/Animation

var played_anim: bool = false
var curr_time_num: float = 0.00

func play_victory(time: float):	
	if !played_anim:
		label_3.hide()
		animation_player.play("mixamo_com")
		played_anim = true
	
	while curr_time_num <= time:
		time_label.text = str("%.2f" % curr_time_num, " secs")
		await get_tree().create_timer(0.0000000001).timeout
		curr_time_num += 0.01

	if time < Score.highest_record:
		Score.highest_record = time
		label_3.show()
		animation.play("yahoo")
		time_label.set("theme_override_colors/font_color", Color.from_rgba8(250, 187, 77, 255)) 
		
