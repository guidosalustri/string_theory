extends Node2D

@onready var smoke: GPUParticles2D = $Path2D/PathFollow2D/Sprite2D/Smoke
@onready var path_follow_2d: PathFollow2D = $Path2D/PathFollow2D
@onready var confettis: Node2D = $Confettis
@onready var _rich_text_label: RichTextLabel = $Control/Label
@onready var timer: Timer = $Timer

@export var main_menu: PackedScene

func _ready() -> void:
	smoke.emitting = true
	for confetti in confettis.get_children():
		confetti.pop_confettis()
		confetti.finished.connect( func() -> void:
			confetti.pop_confettis()
		)
		
	_rich_text_label.visible_ratio = 0.0
	var tween := create_tween()
	var text_appearing_duration: float = _rich_text_label.text.length() / 30.0
	tween.tween_property(_rich_text_label, "visible_ratio", 1.0, text_appearing_duration)
	
	timer.timeout.connect(func() -> void:
		get_tree().change_scene_to_packed(main_menu)
	)

func _process(delta: float) -> void:
	path_follow_2d.progress += 900 * delta
