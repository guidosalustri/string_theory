extends Node

@export var lvls: Array[PackedScene]
@export var cutscene: PackedScene
@export var final_scene: PackedScene
@export var main_menu: PackedScene

@onready var data_collection: DataCollection = $DataCollection

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
	if index == 0 or data_collection.stopwatch_util.is_stopped():
		data_collection.stopwatch_util.start()
	data_collection.stopwatch_util.set_paused(false)
	
	if _lvl_fresh_start:
		GameManager.data_collection.log_level_start_complete(
			GameManager.lvls[index].resource_path.get_file(),
			DataCollection.level_status.START
		)
		_lvl_fresh_start = false
	
	lvl = index
	get_tree().change_scene_to_packed(lvls[index])

func call_main_menu() -> void:
	data_collection.stopwatch_util.stop()

	get_tree().change_scene_to_packed(main_menu)

func _exit_tree() -> void:
	if data_collection.file: # not the best way to do it, but works for now
		data_collection.log_game_quit()
