@tool
class_name Pickup extends Area2D

@export var item: Item = null: set = set_item

@onready var _sprite_2d: Sprite2D = %Sprite2D
@onready var _audio_stream_player: AudioStreamPlayer2D = %AudioStreamPlayer2D
@onready var _animation_player: AnimationPlayer = %AnimationPlayer


func _ready() -> void:
	set_item(item)

	_animation_player.play("idle")
	area_entered.connect(func (body: Area2D) -> void:
		if body is Ship:
			item.use()
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


func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	if item == null:
		warnings.append("The pickup has no item assigned. Please assign an item to the pickup in the inspector.")
	return warnings


func set_item(value: Item) -> void:
	item = value
	if _sprite_2d != null:
		_sprite_2d.texture = item.texture
	if _audio_stream_player != null:
		_audio_stream_player.stream = item.sound_on_pickup
