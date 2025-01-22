extends Node

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var camera_2d: Camera2D = $SubViewport/Camera2D
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var gpu_particles_2d: GPUParticles2D = $Sprite2D/GPUParticles2D
@onready var dialogue_cutscene: Control = $Dialogue_cutscene
@onready var timer: Timer = $Timer



func _ready() -> void:
	dialogue_cutscene.dialogue_done.connect(func() -> void:
		#print("hola")
		animation_player.play("set_the_ship")
	)
	if dialogue_cutscene.visible:
		timer.timeout.connect(_on_timer_timeout)
	#else:
	#	camera_2d.set_process(false)

func _process(_delta: float) -> void:
	pass

func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	if _anim_name == "set_the_ship":
		animation_player.play("Light_speed")
		camera_2d.set_process(true)

	if _anim_name == "Light_speed":
		var tween := create_tween()
		#tween.set_trans(Tween.TRANS_SINE)
		tween.set_trans(Tween.TRANS_EXPO)
		tween.set_ease(Tween.EASE_IN)
		#camera_2d.speed = 300
		#gpu_particles_2d.emitting = true
		tween.tween_property(sprite_2d, "position", Vector2(2500,675), 2)
		await tween.finished
		
		GameManager.next_lvl(GameManager.lvl)

func _on_timer_timeout() -> void:
	camera_2d.set_process(false)
