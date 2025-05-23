extends VBoxContainer


@onready var line_score_scene: PackedScene = preload("res://ui/leaderboard/player_score.tscn")
@onready var label: Label = $Label
@onready var line_edit: LineEdit = $HBoxContainer/LineEdit
@onready var button_ok: Button = $HBoxContainer/ButtonOk
@onready var v_box_container: VBoxContainer = $ScrollContainer/VBoxContainer


@onready var score := time_score_to_string(GameManager.time_score)

signal score_entered

func _ready() -> void:

	label.text = score
	button_ok.pressed.connect(_on_button_pressed)



func _add_line_score() -> void:
	var player_score := line_score_scene.instantiate()
	v_box_container.add_child(player_score)
	player_score.player_name.text = line_edit.text
	player_score.score.text = score
	line_edit.text = ""



func _on_button_pressed() -> void:
	if line_edit.visible == false:
		hide()
		score_entered.emit()
	if line_edit.text.length() == 0:
		return
	_add_line_score()
	line_edit.hide()

func time_score_to_string(time:float) -> String:
	var mins := int(time / 60.0)
	var seconds :=  int( time - mins * 60 )
	var ms := int (( time * 1000.0 - mins * 60 * 1000 - seconds * 1000 ) / 10)
	#text = str( mins ) + ":" + str( seconds ) + "." + str (ms)
	return "%02d:%02d:%002d"%[mins, seconds, (ms%100)]
