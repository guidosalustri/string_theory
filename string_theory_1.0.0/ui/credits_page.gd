extends Control

@onready var container: VBoxContainer = $VBoxContainer

func _ready() -> void:
	modulate.a = 0.0
	visibility_changed.connect( func() -> void: if visible: start_show() )

func start_show() -> void:
	container.position.y = 900.0;
	var move := get_tree().create_tween()
	move.tween_property(container, "position.y", -800, 10.0)
	move.tween_property(self, "modulate.a", 1.0, 2.0)
