extends PanelContainer

var main_scene
var kbm_actions = []
var gamepad_actions = []

@onready var keymapper_gamepad := $VBoxContainer/TabContainer/Gamepad
@onready var keymapper_kbm := $VBoxContainer/TabContainer/Keyboard_Mouse
func _ready():
	setup_kbm_actions()
	setup_gamepad_actions()
	
	keymapper_kbm.setup(kbm_actions)
	keymapper_gamepad.setup(gamepad_actions)
	
func setup_kbm_actions():
	kbm_actions.append("move_up")
	kbm_actions.append("move_down")
	kbm_actions.append("move_left")
	kbm_actions.append("move_right")
	kbm_actions.append("jump")
	kbm_actions.append("interact")
	kbm_actions.append("attack_fast")
	kbm_actions.append("attack_strong")
	kbm_actions.append("evade")
	kbm_actions.append("block")
	kbm_actions.append("special_move")
	kbm_actions.append("lock_target")
	kbm_actions.append("skill1")
	kbm_actions.append("skill2")
	kbm_actions.append("skill3")
	kbm_actions.append("skill4")
	kbm_actions.append("menu_game")
	kbm_actions.append("menu_system")
	
func setup_gamepad_actions():
	#gamepad_actions.append("move_up")
	#gamepad_actions.append("move_down")
	#gamepad_actions.append("move_left")
	#gamepad_actions.append("move_right")
	gamepad_actions.append("jump")
	gamepad_actions.append("interact")
	gamepad_actions.append("attack_fast")
	gamepad_actions.append("attack_strong")
	gamepad_actions.append("evade")
	gamepad_actions.append("block")
	gamepad_actions.append("special_move")
	gamepad_actions.append("skill_trigger")
	gamepad_actions.append("lock_target")
	gamepad_actions.append("menu_game")
	gamepad_actions.append("menu_system")


func _on_btn_exit_button_down():
	main_scene.show_menu("option_menu")
