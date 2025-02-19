extends Node2D

@onready var cut_line: Line2D = $CutLine


func _ready() -> void:
	cut_line.create_line(Vector2(77,98),Vector2(977,98))
