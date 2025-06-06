extends Area2D


@export var canvas_layer : CanvasLayer


func _ready() -> void:
	area_entered.connect(_on_area_entered)



func _on_area_entered(_area:Area2D) -> void:
	if canvas_layer:
		canvas_layer.hide()
