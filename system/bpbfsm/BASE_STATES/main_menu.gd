extends BPBFSM_STATE

func entering():
	if not GameState.gamestate_changed.is_connected(_gamestate_changed):
		GameState.gamestate_changed.connect(_gamestate_changed)
		
func _gamestate_changed():
	# HOW TO DISPLAY CURRENT GAME STATE AS STRING
	#print(GameState._STATE.keys()[GameState.gamestate])
	pass
	
func working(_delta):
	pass
	
func exiting():
	pass

