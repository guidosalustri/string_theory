# ANCHOR: setup
extends Control

## Display speed of the text in characters per second.
const TEXT_DISPLAY_SPEED := 50.0

var lines = [
	"Great!!! You are orbiting your first star. 
	Press 'Ctrl' or 'Spacebar' to eject yourself.",
	"Fly to the next one to connect them.",
	"Well done!! Be mindfull of how the ship
	engine charges while you orbit stars!",
	"Keep in mind that running out of energy
	means losing propulsion...",
#	"Engine is divided in 3 chambers, 1 per thruster \n
#	and they charge independently",
#	"Lateral thrusters will consume energy depending \n
#	on how much they are used and charged depending on \n
#	the direction in which the ship orbits a star.",
#	"Ahh one last thing, try not to overcharge the systems",
]

var _tween: Tween = null

@onready var _label: Label = %Label
# END: setup


# ANCHOR: input
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		_play_dialog()
# END: input


# ANCHOR: play
func _play_dialog() -> void:
	_label.text = lines.pop_front()
	_label.visible_ratio = 0.0

	# If there is another tween playing, stop it
	if _tween != null:
		_tween.kill()

	# We cycle lines of text in the array.
	lines.push_back(_label.text)
	_tween = create_tween()
	_tween.tween_property(_label, "visible_ratio", 1.0, _label.text.length() / TEXT_DISPLAY_SPEED)
# END: play
