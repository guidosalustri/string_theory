@tool
class_name StarsProgress extends GridContainer

@export_range( 1, 20, 0.01 ) var starCount := 1
@export_range( 0, 20, 0.01 ) var connectedStarCount := 0

@onready var star: TextureRect = $Star

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	connectedStarCount = min(starCount, connectedStarCount)
	
	var child_count := get_child_count()
	if child_count != starCount:
		if starCount > child_count:
			for idx in range(child_count, starCount):
				var child := star.duplicate()
				add_child(child);
		else:
			for idx in range(starCount, child_count):
				var child := get_child(idx)
				child.queue_free()

	for idx in range(0, connectedStarCount):
		var child : CanvasItem = get_child(idx);
		child.modulate = Color.hex(0xffe852ff)
	for idx in range(connectedStarCount, starCount):
		var child : CanvasItem = get_child(idx)
		child.modulate = Color.hex(0xffffff33);
