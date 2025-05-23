extends Node2D


@onready var confettis: Node2D = $Confettis
@onready var _rich_text_label: RichTextLabel = $Control/Label
@onready var timer: Timer = $Timer
@onready var node_2d: Node2D = $Control2/Border/Frame/Node2D
@onready var node_2d2: Node2D = $Control3/Border/Frame/Node2D
@onready var leader_board: VBoxContainer = $LeaderBoard

@export var main_menu: PackedScene

func _ready() -> void:
	GameManager.play_in_menu_and_end_music()
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
	leader_board.score_entered.connect(func() -> void:
		timer.start()
	)

func _process(delta: float) -> void:
	node_2d.rotation -= PI * delta
	node_2d2.rotation -= PI * delta
