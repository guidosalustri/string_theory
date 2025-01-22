extends Node

@export var lvls: Array[PackedScene]
@export var cutscene: PackedScene
@export var final_scene: PackedScene
@export var main_menu: PackedScene

var lvl := 0
var deaths_counts := 0

func call_cutscene() -> void:
	if lvl == lvls.size():# tendria que ser una flag corre la ultima cutscene y dsp entra a la final
		get_tree().change_scene_to_packed(final_scene)
	else:
		get_tree().change_scene_to_packed(cutscene)

func next_lvl(index : int) -> void:
	get_tree().change_scene_to_packed(lvls[index])

func call_main_menu() -> void:
	get_tree().change_scene_to_packed(main_menu)

func ship_dead() -> void:
	deaths_counts+=1
