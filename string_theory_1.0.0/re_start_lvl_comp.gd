extends Node


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		GameManager.pop_selector = true
		GameManager.start_lvl(GameManager.lvl)
