extends Control

@onready var container: VBoxContainer = $VBoxContainer

signal credits_over

func _ready() -> void:
	container.modulate.a = 0.0
	visibility_changed.connect( func() -> void: if visible: start_show() else: reset() )

func start_show() -> void:
	var move := get_tree().create_tween()
	move.tween_property(container, "position:y", -385.0, 18.0)
	move.parallel().tween_property(container, "modulate:a", 1.0, 1.5)
	await move.finished
	await get_tree().create_timer(1.0)
	credits_over.emit()

func reset() -> void:
	container.position.y = 1000.0
	container.modulate.a = 0.0

func _unhandled_input(event: InputEvent) -> void:
	if (Input.is_action_just_pressed("exit")):
		if (visible):
			
			credits_over.emit()
