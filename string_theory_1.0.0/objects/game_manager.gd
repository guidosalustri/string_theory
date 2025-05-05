extends Node

@export var lvls: Array[PackedScene]
@export var cutscene: PackedScene
@export var final_scene: PackedScene
@export var main_menu: PackedScene

@onready var data_collection: DataCollection = $DataCollection

@onready var in_game_music_begin: AudioStreamPlayer = $InGameMusicBegin
@onready var in_game_music_loop: AudioStreamPlayer = $InGameMusicLoop
@onready var in_game_music_end: AudioStreamPlayer = $InGameMusicEnd
@onready var dialogue_music: AudioStreamPlayer = $DialogueMusic
@onready var in_menu_and_end_music: AudioStreamPlayer = $MenuAndEndingMusic

var data_collection_impl := preload("res://objects/data_collection/data_collection_impl.gd")

var lvl := 4

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
		play_in_game_music_begin()
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
	if in_menu_and_end_music.playing:
		return
	if in_game_music_begin.playing:
		_stop(in_game_music_begin)
	if in_game_music_loop.playing:
		_stop(in_game_music_loop)
	if in_game_music_end.playing:
		_stop(in_game_music_end)
	if dialogue_music.playing:
		_stop(dialogue_music)
	_play(in_menu_and_end_music)

func play_in_game_music_begin() -> void:
	if dialogue_music.playing:
		_stop(dialogue_music)
	_play(in_game_music_begin, -10.0)
	in_game_music_begin.finished.connect(
		func() -> void:
			play_in_game_music_loop(),
		CONNECT_ONE_SHOT
	)

func play_in_game_music_loop() -> void:
	_play(in_game_music_loop, -5.0, 0.0 )

func play_in_game_music_end() -> void:
	if in_game_music_begin.playing:
		_stop(in_game_music_begin, 3.0)
	if in_game_music_loop.playing:
		_stop(in_game_music_loop, 10.0)
	#if in_game_music_begin.playing:
		#in_game_music_begin.finished.connect(
			#func() -> void: _play(in_game_music_end, -10.0, 0.0 ),
			#CONNECT_ONE_SHOT
		#)
	#if in_game_music_loop.playing:
		#_stop(in_game_music_loop, 3.0)
		#_play(in_game_music_end, -10.0, 3.0)

func play_dialogue_music() -> void:
	if in_game_music_begin.playing:
		_stop(in_game_music_begin, 6.0)
	if in_game_music_loop.playing:
		_stop(in_game_music_loop, 6.0)
	if in_game_music_end.playing:
		_stop(in_game_music_end, 6.0)
	if in_menu_and_end_music.playing:
		_stop(in_menu_and_end_music, 6.5 )
	_play( dialogue_music, -10.0, 6.0 )

func _play(audio: AudioStreamPlayer, volume: float = -1.0, time: float = 3.0) -> void:
	print(audio.name)
	audio.play()
	var tween := get_tree().create_tween()
	tween.tween_property(audio, "volume_db", volume, time)

func _stop(audio: AudioStreamPlayer, time: float = 3.0) -> void:
	if audio.finished.has_connections():
		var connections := audio.finished.get_connections()
		for connection in connections:
			audio.finished.disconnect(connection.callable)
	var tween := get_tree().create_tween()
	tween.tween_property(audio, "volume_db", -40.0, time)
	tween.finished.connect( func() -> void: audio.stop() )
