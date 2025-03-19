extends Node

@export var lvls: Array[PackedScene]
@export var cutscene: PackedScene
@export var final_scene: PackedScene
@export var main_menu: PackedScene

var lvl := 5

var deaths_counts := 0
#var martin_on_ship := false
#var lvl_has_pickups := false

var volume_bus_master := 0
var volume_bus_sfx := 0
var volume_bus_music := 0

func call_cutscene() -> void:
	if lvl == lvls.size():# tendria que ser una flag corre la ultima cutscene y dsp entra a la final
		# this could just go in the lvls array as "last lvl (13)"
		# but is actually just a final cinematic or something.
		get_tree().change_scene_to_packed(final_scene)
	else:
		get_tree().change_scene_to_packed(cutscene)


func start_lvl(index : int) -> void:
	get_tree().change_scene_to_packed(lvls[index])

func call_main_menu() -> void:
	get_tree().change_scene_to_packed(main_menu)

func ship_dead() -> void:
	deaths_counts+=1
