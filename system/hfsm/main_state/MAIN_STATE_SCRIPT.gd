extends HFSM_STATE


func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	
func entering():
	pass
	
func working(_delta):
	match GameState.gamestate:
		GameState._STATE.MAIN_MENU:
			set_next_state("MAIN_MENU")
		GameState._STATE.SYSTEM_MENU:
			set_next_state("SYSTEM_MENU")
		GameState._STATE.GAMEPLAY_MENU:
			set_next_state("GAMEPLAY_MENU")
		GameState._STATE.GAMEPLAY:
			set_next_state("GAMEPLAY")
		GameState._STATE.EVENT:
			set_next_state("EVENT")
		GameState._STATE.DIALOG:
			set_next_state("DIALOG")

func exiting():
	pass

