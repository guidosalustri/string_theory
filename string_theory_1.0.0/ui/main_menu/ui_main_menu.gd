extends Control

var _buttons: Array[ActionTextureButton] = []
var writing_speed := 28.0

@onready var _buttons_v_box_container: VBoxContainer = %ButtonsVBoxContainer
@onready var _cursor_marker: Marker2D = %CursorMarker2D
@onready var _title: Label = $Title

@onready var gpu_particles_2d: GPUParticles2D = $CursorMarker2D/TextureRect/GPUParticles2D

signal options_clicked

var _lastFocused : ActionTextureButton

func _ready() -> void:
	await get_tree().process_frame

	var tween := create_tween()
	var duration := _title.text.length() / writing_speed
	tween.tween_property(_title, "visible_ratio", 1.0, duration)\
	.from(0.0)
	await tween.finished
	
	_buttons.assign(_buttons_v_box_container.find_children("", "TextureButton", false))
	_connect_button_marker_anim()

	# align marker with the first button
	var first_btn := _buttons[0]
	if first_btn:
		_cursor_marker.global_position.y = first_btn.global_position.y + first_btn.size.y / 2.0

	# Allow all buttons to be pressed at the start of the scene.
	_set_buttons_disabled(false)

	get_tree().root.size_changed.connect(_readjust_cursor)

func _connect_button_marker_anim() -> void:
	for button in _buttons:
		var btn_pos := button.global_position + Vector2(-60, button.size.y / 2.0)
		button.mouse_entered.connect(_move_cursor.bind(btn_pos))
		button.focus_entered.connect(_move_cursor.bind(btn_pos))
		button.focus_entered.connect(func() -> void: _lastFocused = button)

		var button_name := button.text.to_lower()
		button.pressed.connect(_on_action_texture_button_pressed.bind(button_name))

func _readjust_cursor() -> void:
	for button in _buttons:
		# Disable old conncections
		button.mouse_entered.disconnect(_move_cursor)
		button.focus_entered.disconnect(_move_cursor)
		# Reconnect with new positions
		var btn_pos := button.global_position + Vector2(-60, button.size.y / 2.0)
		button.mouse_entered.connect(_move_cursor.bind(btn_pos))
		button.focus_entered.connect(_move_cursor.bind(btn_pos))
	
	if _lastFocused:
		var btn_pos := _lastFocused.global_position + Vector2(-60, _lastFocused.size.y / 2.0)
		_move_cursor(btn_pos)

## Disables and prevent buttons from being focused, hides the cursor.
func _set_buttons_disabled(is_disabled: bool) -> void:
	for button in _buttons:
		button.disabled = is_disabled
		button.focus_mode = Control.FOCUS_NONE if is_disabled else Control.FOCUS_ALL

	_lastFocused = null

	# Hide the cursor to help indicate if the buttons are enabled or not.
	_cursor_marker.modulate.a = 0.0
	var final_alpha := 1.0
	if is_disabled:
		_cursor_marker.modulate.a = 1.0
	#	final_alpha = 0.0
	# If we're enabling all buttons, grab the focus of the first button to let non-mouse users navigate the buttons.
	else:
		_buttons[0].grab_focus()

	var cursor_tween := create_tween()
	cursor_tween.tween_property(_cursor_marker, "modulate:a", final_alpha, 0.25)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)

## Tweens the cursor's position to focused ActionButton.
func _move_cursor(at: Vector2) -> void:
	var cursor_tween := create_tween()
	cursor_tween.tween_property(_cursor_marker, "global_position", at, 0.5)\
		.set_trans(Tween.TRANS_QUART)\
		.set_ease(Tween.EASE_OUT)

func _on_action_texture_button_pressed( button_name: String) -> void:
	match button_name:
		"play":
			GameManager.enable_data_collection()
			_set_buttons_disabled(true)
			var disable_tween := create_tween()
			disable_tween.tween_property(_buttons_v_box_container,"modulate:a", 0.0, 1.0)\
			.set_trans(Tween.TRANS_QUART)\
			.set_ease(Tween.EASE_OUT)

			gpu_particles_2d.emitting = true
			disable_tween.parallel().tween_property(_cursor_marker,"position:x", 2500, 3.0)\
			.set_trans(Tween.TRANS_QUAD)\
			.set_ease(Tween.EASE_IN_OUT)
			
			for button in _buttons:
				button.mouse_entered.disconnect(_move_cursor)
				button.focus_entered.disconnect(_move_cursor)
			
			await disable_tween.finished
			#_set_buttons_disabled(true)
			#GameManager.next_lvl(GameManager.lvl)
			GameManager.call_cutscene()
		"options":
			options_clicked.emit()
		"credits":
			pass
		"exit":
			GameManager.data_collection.log_game_quit(DataCollection.game_quit_cause.MENU)
			get_tree().quit()
