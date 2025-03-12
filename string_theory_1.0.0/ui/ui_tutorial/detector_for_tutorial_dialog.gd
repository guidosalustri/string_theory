extends Area2D


@export var dialog : DialogTutorial

func _ready() -> void:
	area_entered.connect(_on_area_entered)


func _on_area_entered(_area:Area2D) -> void:
	if dialog:
		dialog.play_dialog()
		dialog.allow_input_for_dialog = true
		area_entered.disconnect(_on_area_entered)
