extends Control

@onready var animation_player: AnimationPlayer = $AnimationPlayer
var dash_count := 0


func dash_used() -> void:
	if dash_count < 1:
		animation_player.play("dash1")
	elif dash_count==1:
		animation_player.play("dash")
	else:
		animation_player.play("no_dash")
	dash_count+=1
