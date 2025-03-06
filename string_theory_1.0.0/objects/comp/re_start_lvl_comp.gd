extends Node


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		GameManager.start_lvl(GameManager.lvl)
