extends Node

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var camera_2d: Camera2D = $SubViewport/Camera2D
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var gpu_particles_2d: GPUParticles2D = $Sprite2D/GPUParticles2D
@onready var dialogue_cutscene: Control = $CanvasLayer/Dialogue_cutscene
@onready var timer: Timer = $Timer
@onready var label: Label = $CanvasLayer/Label



func _ready() -> void:
	dialogue_cutscene.dialogue_done.connect(func() -> void:
		animation_player.play("set_the_ship")
	)
	if dialogue_cutscene.visible:
		timer.timeout.connect(_on_timer_timeout)
	score()

func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	if _anim_name == "set_the_ship":
		animation_player.play("Light_speed")
		camera_2d.set_process(true)

	if _anim_name == "Light_speed":
		var tween := create_tween()

		tween.set_trans(Tween.TRANS_EXPO)
		tween.set_ease(Tween.EASE_IN)
		tween.tween_property(sprite_2d, "position", Vector2(2500,675), 2)
		await tween.finished
		
		GameManager.start_lvl(GameManager.lvl)

func _on_timer_timeout() -> void:
	camera_2d.set_process(false)

func score() -> void:
	var value : float = GameManager.time_score
	var mins := int(value / 60.0)
	var seconds :=  int( value - mins * 60 )
	var ms := int (( value * 1000.0 - mins * 60 * 1000 - seconds * 1000 ) / 10)
	#text = str( mins ) + ":" + str( seconds ) + "." + str (ms)
	label.text = "%02d:%02d:%002d"%[mins, seconds, (ms%100)]
