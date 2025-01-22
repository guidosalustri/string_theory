extends Camera2D

@export var speed := 450
@onready var sub_viewport: SubViewport = $".."

func _ready() -> void:
	#print(get_viewport().size)
	#print(sub_viewport.size)
	pass

func _process(delta):
	translate((Vector2.RIGHT * speed) * delta)
