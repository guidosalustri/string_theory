@tool
extends Control

## Controls how much the menu is opened. This isn't actually used in the running game
## but it allows us to preview the menu animation in the editor.
@export_range(0, 1.0) var menu_opened_amount := 0.0: 
	set = set_menu_opened_amount
## How fast the pause menu opens
@export_range(0.1, 10.0, 0.01, "or greater") var opening_speed := 2.3

@onready var _blur_color_rect: ColorRect = %BlurColorRect
@onready var _ui_panel_container: PanelContainer = %UIPanelContainer
@onready var resume_button: Button = %ResumeButton
@onready var quit_button: Button = %QuitButton
@onready var options_button: Button = %OptionsButton
@onready var options: Control = $options

var _tween: Tween


func _ready() -> void:
	# This is a @tool script, so we exit early if we're running in the editor.
	if Engine.is_editor_hint():
		return

	# We make sure at the beginning, the menu is not shown
	menu_opened_amount = 0.0
	resume_button.pressed.connect(toggle.bind(false))
	quit_button.pressed.connect(func() -> void:
		get_tree().paused = false
		GameManager.call_main_menu()
	)
	options_button.pressed.connect(func() -> void:
		options.show()
		#options.button_cancel_text.grab_focus()
		)
	options.cancel_clicked.connect(func() -> void:
		options.hide()
		resume_button.grab_focus()
	)



## Called when [member menu_opened_amount] is changed.
func set_menu_opened_amount(amount: float) -> void:
	visible = amount > 0
	# we set the value
	menu_opened_amount = amount
	# we ensure the nodes exist (in case the function gets called before _ready)
	if _ui_panel_container == null or _blur_color_rect == null:
		return
	# we lerp all the values between 0 and 1, the two regular extremes of the 
	# menu_opened_amount variable.
	# first, the shader. We set the blur amount and the saturation
	_blur_color_rect.material.set_shader_parameter("blur_amount", lerp(0.0, 1.5, amount))
	_blur_color_rect.material.set_shader_parameter("saturation", lerp(1.0, 0.3, amount))
	_ui_panel_container.modulate.a = amount
	# We want to pause the game, but not in the editor
	if not Engine.is_editor_hint():
		# this pauses the whole game, but since the top node has a process mode
		# of ALWAYS, it won't pause. The game itself has a process mode of WHEN_PAUSED,
		# so it'll stop
		get_tree().paused = amount > 0.3


func toggle(is_toggled: bool) -> void:
	var speed := opening_speed
	# if there's a tween, and it is animating, kill it.
	# just checking for `null` isn't enough,
	if _tween != null and _tween.is_valid():
		# if the previous tween was animating, we want to animate back by the exact
		# elapsed time
		speed = _tween.get_total_elapsed_time()
		_tween.kill()

	_tween = create_tween()
	# make the tween feel nice
	_tween.set_ease(Tween.EASE_OUT)
	_tween.set_trans(Tween.TRANS_QUART)
	# We want to animate the "menu_opened_amount" property to 1.0 if toggled,
	# or to 0 otherwise
	var target := 1.0 if is_toggled else 0.0
	# We animate the property
	_tween.tween_property(self, "menu_opened_amount", target, speed)
	if is_toggled:
		#await _tween.finished
		await get_tree().process_frame
		resume_button.focus_mode = Control.FOCUS_ALL
		options_button.focus_mode = Control.FOCUS_ALL
		quit_button.focus_mode = Control.FOCUS_ALL
		resume_button.grab_focus()
		


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		toggle(true if menu_opened_amount < 0.5 else false)
