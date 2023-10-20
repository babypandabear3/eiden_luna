extends HFSM_STATE


func entering():
	GameState.gamestate = GameState._STATE.GAMEPLAY
	blackboard.main.main_menu_as_top()
	blackboard.main.show_top_menu()
	pass
	
func working(_delta):
	pass
	
func exiting():
	pass

