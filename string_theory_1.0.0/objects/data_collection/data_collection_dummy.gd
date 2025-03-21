class_name DataCollectionDummy extends DataCollection

func start_write():
	pass

func log_attach_detach_to_star( _action: ship_action, _energy_level_normalized: float ) -> void:
	pass

func log_level_start_complete( _level_name: String, _status: level_status ) -> void:
	pass

func log_game_complete( ) -> void:
	pass

func log_game_quit( _cause: game_quit_cause = game_quit_cause.UNKNOWN  ) -> void:
	pass

func log_level_quit( ) -> void:
	pass

func log_player_death( _cause: player_death_cause ) -> void:
	pass

func log_run_out_of_fuel( ) -> void:
	pass

func log_player_pos( _pos: Vector2 ) -> void:
	pass
