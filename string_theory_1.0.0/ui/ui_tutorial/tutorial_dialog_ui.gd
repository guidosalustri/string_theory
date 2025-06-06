class_name DialogTutorial extends Control


const TEXT_DISPLAY_SPEED := 50.0

var lines = [
#	"Great!!! You are orbiting your first star.\
#	\nPress [color=3ba2f9]'Ctrl'[/color] or [color=3ba2f9]'Spacebar'[/color] to eject yourself.",
	"",
	"Fly to the next star to [color=3ba2f9]connect[/color] them.",
	"",
#	"Well done!! Be mindful of how the ship\
#	\nengine [color=3ba2f9]charges[/color] while you [color=3ba2f9]orbit[/color] stars!",
	"Avoid [color=3ba2f9]overcharging[/color] the engine",
#	"But keep in mind that running out of energy\
#	\nmeans [color=3ba2f9]losing propulsion[/color]...",
	"",
#	"Engine is divided in 3 chambers, 1 per thruster \n
#	and they charge independently",
#	"Lateral thrusters will consume energy depending \n
#	on how much they are used and charged depending on \n
#	the direction in which the ship orbits a star.",
#	"Ahh one last thing, try not to overcharge the systems",
]

var _tween: Tween = null
var allow_input_for_dialog := false
var index :=0
var labels :=[]
#@onready var rich_text_label1: RichTextLabel = $CenterContainer/PanelContainer/RichTextLabel
@onready var rich_text_label: RichTextLabel = $RichTextLabel
@onready var rich_text_label_2: RichTextLabel = $RichTextLabel2


func _ready() -> void:
	labels = get_children()#[rich_text_label, rich_text_label_2]
	rich_text_label.visible_ratio = 0.0
	rich_text_label_2.visible_ratio = 0.0

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("spin") and  allow_input_for_dialog:
		play_dialog()
		allow_input_for_dialog=false

func play_dialog() -> void:
#	if lines:
#		rich_text_label.text = lines.pop_front()
#		rich_text_label.visible_ratio = 0.0
	# If there is another tween playing, stop it
	if index<labels.size():
		if _tween != null:
			_tween.kill()

		#lines.push_back(rich_text_label.text)
		_tween = create_tween()
		_tween.tween_property(labels[index], "visible_ratio", 1.0, labels[index].text.length() / TEXT_DISPLAY_SPEED)
		index+=1
