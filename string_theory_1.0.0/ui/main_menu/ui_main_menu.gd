extends Control

var _buttons: Array[ActionTextureButton] = []
var writing_speed := 28.0

@onready var _buttons_v_box_container: VBoxContainer = %ButtonsVBoxContainer
@onready var _cursor_marker: Marker2D = %CursorMarker2D
@onready var _label: Label = $Label

@onready var gpu_particles_2d: GPUParticles2D = $CursorMarker2D/TextureRect/GPUParticles2D

#@export var game: PackedScene
#@export var options: PackedScene

signal options_clicked

func _ready() -> void:
	await get_tree().process_frame

	var tween := create_tween()
	var duration := _label.text.length() / writing_speed
	tween.tween_property(_label, "visible_ratio", 1.0, duration)\
	.from(0.0)
	await tween.finished
	
	_buttons.assign(_buttons_v_box_container.find_children("", "TextureButton", false))

	for button in _buttons:
		
		var btn_pos := button.global_position + Vector2(30,0)
		button.mouse_entered.connect(_move_cursor.bind(btn_pos))
		button.focus_entered.connect(_move_cursor.bind(btn_pos))
		
		var button_name := button.text.to_lower()
		button.pressed.connect(_on_action_texture_button_pressed.bind(button_name))
	# Allow all buttons to be pressed at the start of the scene.
	_set_buttons_disabled(false)
	
	
	

## Disables and prevent buttons from being focused, hides the cursor.
func _set_buttons_disabled(is_disabled: bool) -> void:
	for button in _buttons:
		button.disabled = is_disabled
		button.focus_mode = Control.FOCUS_NONE if is_disabled else Control.FOCUS_ALL

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
	cursor_tween.tween_property(_cursor_marker, "position", at, 0.5)\
		.set_trans(Tween.TRANS_QUART)\
		.set_ease(Tween.EASE_OUT)


func _on_action_texture_button_pressed( button_name: String) -> void:
	
	#assert(_animation_player.get_animation_list().has(animation_name), "Animation '%s' does not exist"%[animation_name])
	#_animation_player.play(animation_name)
	
#	var disable_tween := create_tween()
#	disable_tween.tween_property(_buttons_v_box_container,"modulate:a", 0.0, 1.0)\
#	.set_trans(Tween.TRANS_QUART)\
#	.set_ease(Tween.EASE_OUT)
#
	#gpu_particles_2d.emitting = true
	#disable_tween.parallel().tween_property(_cursor_marker,"position:x", 2500, 3.0)\
	#.set_trans(Tween.TRANS_QUAD)\
	#.set_ease(Tween.EASE_IN_OUT)
#
	#await disable_tween.finished
	#_set_buttons_disabled(true)

	match button_name:
		"play":
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
		"exit":
			get_tree().quit()
