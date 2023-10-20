@tool
extends HSplitContainer

var quest_panel : PanelContainer
var log_panel : PanelContainer

func _ready():
	quest_panel = $quest_panel
	log_panel = $log_panel

func _on_dragged(offset):
	quest_panel.fix_size()
	log_panel.fix_size()
