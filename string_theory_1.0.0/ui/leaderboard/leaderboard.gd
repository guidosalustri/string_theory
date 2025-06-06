extends VBoxContainer

@onready var line_score_scene: PackedScene = preload("res://ui/leaderboard/player_score.tscn")
@onready var label: Label = $Label
@onready var line_edit: LineEdit = $HBoxContainer/LineEdit
@onready var button_ok: Button = $HBoxContainer/ButtonOk
@onready var v_box_container: VBoxContainer = $ScrollContainer/VBoxContainer
@onready var animation_player: AnimationPlayer = $HBoxContainer/AnimationPlayer


@onready var score := time_score_to_string(GameManager.time_score)

var ls:Array
var pos_new_score := 0
var blue : Color =  Color(0.231,0.635,0.976,1)
var yellow : Color = Color(1,0.835,0,1)
var player_name

signal score_entered

func _ready() -> void:
	button_ok.disabled = true
	ls = await GameManager.load_leaderbaord()
	button_ok.disabled = false
	label.text = score
	button_ok.pressed.connect(_on_button_pressed)
	for i in range(ls.size()):
		if GameManager.time_score > ls[i][1]:
			pos_new_score+=1
		item_in_leaderboard(ls[i],i)

func _add_line_score() -> void:
	var has_user: bool = ls.any( func (row: Array) -> bool:
			return row[0].to_lower() == line_edit.text
	)

	if has_user:
		animation_player.play("name_taken")
		await animation_player.animation_finished
		line_edit.text = ""
		return
	
	player_name = line_edit.text
	player_name = player_name.to_lower()
	var element_ls :Array= [line_edit.text,GameManager.time_score]
	ls.insert(pos_new_score,element_ls)
	for i in range(ls.size()):
		if i<ls.size()-1:
			v_box_container.get_child(i).queue_free()
		item_in_leaderboard_reload(ls[i],i)
	line_edit.text = ""
	line_edit.hide()

func _on_button_pressed() -> void:
	if line_edit.visible == false:
		hide()
		SilentWolf.Scores.save_score(player_name, GameManager.time_score)
		score_entered.emit()
	
	if line_edit.text.length() == 0:
		return
	_add_line_score()

func time_score_to_string(time:float) -> String:
	var mins := int(time / 60.0)
	var seconds :=  int( time - mins * 60 )
	var ms := int (( time * 1000.0 - mins * 60 * 1000 - seconds * 1000 ) / 10)
	#text = str( mins ) + ":" + str( seconds ) + "." + str (ms)
	return "%02d:%02d:%002d"%[mins, seconds, (ms%100)]

func item_in_leaderboard(player:Array, pos: int) -> void:
	var player_score := line_score_scene.instantiate()
	v_box_container.add_child(player_score)
	var player_pos_name := str(pos)+". "+str(player[0])
	player_score.player_name.text = player_pos_name
	player_score.score.text = time_score_to_string(player[1])
	if pos%2 ==1:
		player_score.player_name.add_theme_color_override("font_color", yellow)
		player_score.score.add_theme_color_override("font_color", blue)


func item_in_leaderboard_reload(player:Array, pos: int) -> void:
	var player_score := line_score_scene.instantiate()
	v_box_container.add_child(player_score)
	var player_pos_name := str(pos)+". "+str(player[0])
	player_score.player_name.text = player_pos_name
	player_score.score.text = time_score_to_string(player[1])
	if pos ==pos_new_score:
		player_score.player_name.add_theme_color_override("font_color", Color.WHITE)
		player_score.score.add_theme_color_override("font_color", Color.WHITE)
	if pos%2 ==1:
		player_score.player_name.add_theme_color_override("font_color", yellow)
		player_score.score.add_theme_color_override("font_color", blue)
