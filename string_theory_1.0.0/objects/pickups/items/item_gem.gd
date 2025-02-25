class_name ItemGem extends Item

@export var amount := 1


func use() -> void:
	GameManager.gems += amount
