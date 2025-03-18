extends Control


# key are lvl; value is a list of sentences. If list is empty no dialogue
# to display and this scene should be hiden in the cutscene
@export var dialogue_per_scene_dic = {}


@onready var _texture_button: TextureButton = %TextureButton
@onready var _rich_text_label: RichTextLabel = %RichTextLabel
@onready var _audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var portrait: Control = $Portrait

var sentences: Array
var _tween: Tween = null
var _current_sentence := 0
var allow_input := true
signal dialogue_done


func _ready() -> void:
	sentences = dialogue_per_scene_dic[GameManager.lvl]
	if len(sentences) == 0:
		hide()
	else:
		_texture_button.pressed.connect(_advance_dialog)
		_advance_dialog()
	
	if GameManager.lvl == 9 or GameManager.lvl == 10:
		portrait.set_current_state(portrait.States.MAVERICK)

func _process(_delta: float) -> void:
	if len(sentences) == 0:
		dialogue_done.emit()
		allow_input = false
		set_process(false)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") and allow_input:
		_advance_dialog()

func _advance_dialog() -> void:
	# Finish the dialog if it's not done yet.
	if _current_sentence > sentences.size():
		return
	if _tween != null and _tween.is_running():
		_tween.stop()
		_rich_text_label.visible_ratio = 1.0
		_texture_button.visible = true
		_audio_stream_player.stop()
		#_current_sentence = _current_sentence + 1
		return
	if _current_sentence == sentences.size():
		fade_out()
		_current_sentence = _current_sentence + 1
		return

	# Otherwise, start the next piece of dialog.
	_texture_button.visible = false
	_rich_text_label.text = sentences[_current_sentence].text
	_rich_text_label.visible_ratio = 0.0
	var text_appearing_duration: float = len(_rich_text_label.text) / 60.0
	# We cycle lines of text in the array by pushing and popping its contents.
	#lines.push_back(_rich_text_label.text)
	# Interpolation speed is based on text length.
	_tween = create_tween()
	_tween.tween_property(
		_rich_text_label, "visible_ratio", 1.0, text_appearing_duration
	)
	# We randomize the audio playback's start time to make it sound different
	# every time and play the sound until the text finishes displaying.
	var sound_max_length := _audio_stream_player.stream.get_length() - text_appearing_duration
	var sound_start_position := randf() * sound_max_length
	_audio_stream_player.play(sound_start_position)
	_tween.finished.connect( func() -> void:
		_audio_stream_player.stop()
		)
	_tween.tween_callback(_texture_button.set_visible.bind(true))
	_current_sentence = _current_sentence + 1

func fade_out() -> void:
	dialogue_done.emit()
	allow_input = false
	portrait.pop_out()
	var tween := create_tween()
	tween.parallel().tween_property(self, "modulate:a", 0, 0.8)
	#.set_trans(Tween.TRANS_ELASTIC)
	#tween.set_ease(Tween.EASE_IN)
