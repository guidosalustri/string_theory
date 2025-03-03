class_name Pickup extends Area2D

@export var item: Item = null: set = set_item

@onready var _sprite_2d: Sprite2D = %Sprite2D
@onready var _audio_stream_player: AudioStreamPlayer2D = %AudioStreamPlayer2D
@onready var _animation_player: AnimationPlayer = %AnimationPlayer

var not_spawn_yet := true
signal has_spawn

func _ready() -> void:
	set_item(item)
	hide()
	set_process(false)
	monitoring = false
	monitorable = false
	scale = Vector2(0,0)

	area_entered.connect(func (area: Area2D) -> void:
		if area is Ship:
			item.use()
			if not area.turn_right:
				area.turn_right=true
			elif not area.move_forward:
				area.move_forward=true
			elif not area.turn_left:
				area.turn_left=true
			#print(GameManager.gems)
		_animation_player.play("destroy")
		# Disable collision monitoring to prevent picking up the item multiple times
		set_deferred("monitoring", false)
		# Play the pickup's sound effect and wait for the destroy animation to
		# finish, to leave time for the sound to play before the pickup is
		# removed from the scene
		_audio_stream_player.play()
		_animation_player.animation_finished.connect(func (_animation_name: String) -> void:
			queue_free()
		)
	)

func spawn():
	if not_spawn_yet:
		show()
		set_process(true)
		set_deferred("monitoring", true)
		set_deferred("monitorable", true)
		var tween:  Tween = create_tween()
		tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "scale",Vector2(1,1),0.25)
		await tween.finished
		_animation_player.play("idle")
		has_spawn.emit()
		not_spawn_yet = false


func set_item(value: Item) -> void:
	item = value
	if _sprite_2d != null:
		_sprite_2d.texture = item.texture
	if _audio_stream_player != null:
		_audio_stream_player.stream = item.sound_on_pickup
