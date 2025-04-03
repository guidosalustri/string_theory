extends Control

@onready var container: VBoxContainer = $VBoxContainer

signal credits_over

var showTween: Tween

func start_show() -> void:
	container.position.y = 1000
	container.modulate.a = 1.0
	show()
	set_process_input(true)
	showTween = create_tween()
	# Scroll up
	showTween.tween_property(container, "position:y", -385.0, 18.0)
	showTween.tween_interval(0.5)
	# Fade out
	showTween.tween_property(container, "modulate:a", 0.0, 1.5)
	showTween.tween_callback(hide)
	showTween.tween_callback(credits_over.emit)

func _unhandled_input(event: InputEvent) -> void:
	if (event.is_action_pressed("exit")):
		if (visible):
			set_process_input(false)
			showTween.kill()
			hide()
			credits_over.emit()
	
