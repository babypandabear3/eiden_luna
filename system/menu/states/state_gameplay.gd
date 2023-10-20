extends HFSM_STATE


func entering():
	GameState.gamestate = GameState._STATE.GAMEPLAY
	pass
	
func working(_delta):
	pass
	
func exiting():
	pass

