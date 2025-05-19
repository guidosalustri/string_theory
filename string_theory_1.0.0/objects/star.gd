class_name Star extends Area2D

# so far the main scene has a camera and is swap from ship to star to ship to next star
# maybe it will be better for each entity to has its own camera
@onready var sprite_2d: Sprite2D = $CanvasGroup/Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sparks: GPUParticles2D = $Sparks
@onready var particles_black_hole_2d: Sprite2D = $ParticlesBlackHole2D
@onready var timer: Timer = $Timer
@onready var animation_player_2: AnimationPlayer = $AnimationPlayer2

var has_spawn_already := false
signal star_entered
signal has_spawn
@export var black_hole_on_star := false
@export var time_between_star_blackhole : int = 1


enum States {
	STAR,
	BLACK_HOLE
}

var current_state: States = States.STAR:
	set = set_current_state

func set_current_state(new_state: States) -> void:
	current_state = new_state


func _ready() -> void:
	area_entered.connect(_on_area_entered)
	timer.timeout.connect(_on_timer_timeout)
	animation_player.animation_finished.connect(func(anim_name)-> void:
		if anim_name == "black_hole_transition" or \
		anim_name == "star_transition":
			timer.start()
		if anim_name == "star_transition":
			animation_player_2.play("spawn")
		)
	# star "spawn" as lvl progress
	hide()
	set_process(false)
	monitoring = false
	monitorable = false
	scale = Vector2(0,0)
	particles_black_hole_2d.show()
	particles_black_hole_2d.modulate.a = 0
	timer.wait_time = time_between_star_blackhole

func spawn():
	sparks.emitting = false
	show()
	set_process(true)
	set_deferred("monitoring", true)
	set_deferred("monitorable", true)
	var tween:  Tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale",Vector2(1,1),0.25)

	await tween.finished

	animation_player_2.play("spawn")
	if not has_spawn_already:
		for child in get_children():
			if child.is_in_group("obstacles"):
				child.activate(1)
			if child.is_in_group("spinner_bh"):
				for lower_lvl_child in child.get_children():
					if lower_lvl_child.is_in_group("obstacles"):
						lower_lvl_child.activate(1)
	has_spawn.emit()
	has_spawn_already= true
	if black_hole_on_star:
		timer.start()


func _on_area_entered(_area: Area2D) -> void:
	star_entered.emit()
	if animation_player.is_playing():
		if animation_player.get_current_animation() == "black_hole_transition" \
		and current_state == States.STAR :
			animation_player.play_backwards()
		elif animation_player.get_current_animation() == "star_transition" \
		and current_state == States.BLACK_HOLE :
			animation_player.play_backwards()
		await animation_player.animation_finished
	animation_player_2.stop()
	timer.stop()
	sparks.emitting = true


func _on_timer_timeout() -> void:
	match current_state:
		States.STAR:
			animation_player.play("black_hole_transition")
		States.BLACK_HOLE:
			animation_player.play("star_transition")


func activate() -> void:
	set_deferred("monitoring", true)
	set_deferred("monitorable", true)
	z_index= 0

func deactivate() -> void:
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	z_index= -1

func play_floating_animation() -> void:
	var tween := create_tween()
	tween.set_loops()
	tween.set_trans(Tween.TRANS_SINE)

	var position_offset := Vector2(0.0, 4.0)
	var duration = randf_range(0.8, 1.2)
	sprite_2d.position = -1.0 * position_offset
	tween.tween_property(sprite_2d, "position", position_offset, duration)
	tween.tween_property(sprite_2d, "position",  -1.0 * position_offset, duration)


func is_state_star() -> bool:
	return current_state == States.STAR
