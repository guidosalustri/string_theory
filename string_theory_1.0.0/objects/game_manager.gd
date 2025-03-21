extends Node

@export var lvls: Array[PackedScene]
@export var cutscene: PackedScene
@export var final_scene: PackedScene
@export var main_menu: PackedScene

@onready var data_collection: DataCollection = $DataCollection

var data_collection_impl := preload("res://objects/data_collection/data_collection_impl.gd")

var lvl := 0

var deaths_counts := 0
#var martin_on_ship := false
#var lvl_has_pickups := false

var volume_bus_master := 0
var volume_bus_sfx := 0
var volume_bus_music := 0

var _lvl_fresh_start := false

func call_cutscene() -> void:
	_lvl_fresh_start = true
	if lvl == lvls.size() - 1:# tendria que ser una flag corre la ultima cutscene y dsp entra a la final
		# this could just go in the lvls array as "last lvl (13)"
		# but is actually just a final cinematic or something.
		data_collection.log_game_complete()
		get_tree().change_scene_to_packed(final_scene)
	else:
		get_tree().change_scene_to_packed(cutscene)

func start_lvl(index : int) -> void:
	if _lvl_fresh_start:
		GameManager.data_collection.log_level_start_complete(
			GameManager.lvls[index].resource_path.get_file(),
			DataCollection.level_status.START
		)
		_lvl_fresh_start = false
	
	lvl = index
	get_tree().change_scene_to_packed(lvls[index])

func call_main_menu() -> void: 
	get_tree().change_scene_to_packed(main_menu)

func _exit_tree() -> void:
	data_collection.log_game_quit()

func enable_data_collection() -> void:
	data_collection.set_script(data_collection_impl)
	data_collection.start_write()
