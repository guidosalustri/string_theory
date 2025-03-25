class_name DataCollection extends Node

@warning_ignore("unused_signal")
signal game_paused( value: bool )

enum ship_action {
	ATTACH,
	DETACH
}

var ship_action_value := {
	ship_action.ATTACH: "attach",
	ship_action.DETACH: "detach"
}

enum level_status {
	START,
	COMPLETE
}

var level_status_value := {
	level_status.START: "start",
	level_status.COMPLETE: "complete"
}

enum game_quit_cause {
	MENU,
	UNKNOWN
}

var game_quit_cause_value := {
	game_quit_cause.MENU: "menu",
	game_quit_cause.UNKNOWN: "unknown"
}

enum player_death_cause {
	BLACK_HOLE,
	ASTEROID,
	STAR_COLISSION,
	OVERCHARGE,
	OUT_OF_FUEL,
	STRAY
}

var player_death_cause_value := {
	player_death_cause.BLACK_HOLE: "black_hole",
	player_death_cause.ASTEROID: "asteroid",
	player_death_cause.STAR_COLISSION: "star_colission",
	player_death_cause.OVERCHARGE: "overcharge",
	player_death_cause.OUT_OF_FUEL: "out_of_fuel",
	player_death_cause.STRAY: "stray"
}

func start_write():
	push_error("UNIMPLEMENTED ERROR: DataCollection.start_write()")

# Logging
func log_attach_detach_to_star( _action: ship_action, _energy_level_normalized: float ) -> void:
	push_error("UNIMPLEMENTED ERROR: DataCollection.log_attach_detach_to_star()")

func log_aim_score( _aim_score: float) -> void:
	push_error("UNIMPLEMENTED ERROR: DataCollection.log_aim_score()")

func log_level_start_complete( _level_name: String, _status: level_status ) -> void:
	push_error("UNIMPLEMENTED ERROR: DataCollection.log_level_start_complete()")

func log_game_complete( ) -> void:
	push_error("UNIMPLEMENTED ERROR: DataCollection.log_game_complete()")

func log_game_quit( _cause: game_quit_cause = game_quit_cause.UNKNOWN  ) -> void:
	push_error("UNIMPLEMENTED ERROR: DataCollection.log_game_quit()")

func log_level_quit( ) -> void:
	push_error("UNIMPLEMENTED ERROR: DataCollection.log_level_quit()")

func log_player_death( _cause: player_death_cause ) -> void:
	push_error("UNIMPLEMENTED ERROR: DataCollection.log_player_death()")

func log_run_out_of_fuel( ) -> void:
	push_error("UNIMPLEMENTED ERROR: DataCollection.log_run_out_of_fuel()")

func log_player_pos( _pos: Vector2, _rotation: float ) -> void:
	push_error("UNIMPLEMENTED ERROR: DataCollection.log_player_pos()")
