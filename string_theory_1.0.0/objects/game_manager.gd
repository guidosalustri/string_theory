extends Node

@export var lvls: Array[PackedScene]
@export var cutscene: PackedScene
@export var final_scene: PackedScene
@export var main_menu: PackedScene

@onready var data_collection: DataCollection = $DataCollection

@onready var in_game_music: AudioStreamPlayer = $InGameMusic
@onready var in_menu_and_end_music: AudioStreamPlayer = $InMenuAndEndMusic

var data_collection_impl := preload("res://objects/data_collection/data_collection_impl.gd")

var lvl := 0

var deaths_counts := 0
#var martin_on_ship := false
#var lvl_has_pickups := false

var volume_bus_master := 0
var volume_bus_sfx := 0
var volume_bus_music := 0

# fresh start means when level is started after cutscene
# death and restart don't count
var _lvl_fresh_start := false

func call_cutscene() -> void:
	_lvl_fresh_start = true
	if lvl == lvls.size():# - 1:# tendria que ser una flag corre la ultima cutscene y dsp entra a la final
		# this could just go in the lvls array as "last lvl (13)"
		# but is actually just a final cinematic or something.
		data_collection.log_game_complete()
		get_tree().change_scene_to_packed(final_scene)
	else:
		get_tree().change_scene_to_packed(cutscene)

func start_lvl(index : int) -> void:
	if _lvl_fresh_start:
		play_in_game_music()
		GameManager.data_collection.log_level_start_complete(
			GameManager.lvls[index].resource_path.get_file(),
			DataCollection.level_status.START
		)
		_lvl_fresh_start = false
		#audio_stream_player.
	
	lvl = index
	get_tree().change_scene_to_packed(lvls[index])

func call_main_menu() -> void: 
	get_tree().change_scene_to_packed(main_menu)

func _exit_tree() -> void:
	data_collection.log_game_quit()

func enable_data_collection() -> void:
	data_collection.set_script(data_collection_impl)
	data_collection.start_write()

func play_in_menu_and_end_music() -> void:
	_stop(in_game_music)
	_play(in_menu_and_end_music)

func play_in_game_music() -> void:
	if not in_game_music.playing:
		_stop(in_menu_and_end_music)
		_play(in_game_music)

func _play(audio: AudioStreamPlayer) -> void:
	audio.play()
	var tween := get_tree().create_tween()
	tween.tween_property(audio, "volume_db", -1.0, 3)

func _stop(audio: AudioStreamPlayer) -> void:
	var tween := get_tree().create_tween()
	tween.tween_property(audio, "volume_db", -40.0, 3)
	tween.finished.connect( func() -> void: audio.stop() )
