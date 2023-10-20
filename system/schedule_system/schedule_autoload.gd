extends Node

enum _LOCATION {
	HOME,
	STORE,
	RESTAURANT,
	ACADEMY,
}

enum _ACTION {
	GO_HOME,
	WORK,
	BUY_MEAT,
	BUY_VEGETABLE,
	EAT,
	DRINK,
}

var data : Dictionary

func _ready():
	var file = "res://system/schedule_system/data/npc_schedule.json"
	var json_as_text = FileAccess.get_file_as_string(file)
	var json_as_dict = JSON.parse_string(json_as_text)
	
	var default_action = {}
	default_action["h00"] = _ACTION.GO_HOME
	default_action["h07"] = _ACTION.WORK
	default_action["h12"] = _ACTION.EAT
	default_action["h13"] = _ACTION.WORK
	default_action["h19"] = _ACTION.DRINK
	default_action["h22"] = _ACTION.GO_HOME
	
	var schedule_key_size = _ACTION.keys().size()
	var schedule_keys_as_str = []
	for i in schedule_key_size:
		schedule_keys_as_str.append(_ACTION.keys()[i])
	
	if json_as_dict:
		var columns = json_as_dict["columns"]
		var cols = []
		for c in columns:
			cols.append(c.name)
		
		for d in json_as_dict["rows"]:
			#reading data from json and put them into dictionary
			var row = {}
			var i = 0
			var key = d[0]
			for c in cols:
				var res = d[i]
				if str(res) == "<null>":
					res = -1
				var tmp_result = schedule_keys_as_str.find(str(res))
				if tmp_result > -1:
					res = tmp_result
					
				row[c] = res
				
				i += 1
				
			#Inserting default value to empty slot
			for k in default_action.keys():
				if row.has(k) :
					if row[k] == -1:
						row[k] = default_action[k]
			
			#fill empty slot with values before them
			var idx = 24
			var prev = -1
			for j in idx:
				var k = str(j) 
				if k.length() == 1:
					k = "0" + k
				k = "h" + k
				
				if row[k] == -1:
					row[k] = prev
				else:
					prev = row[k]

			data[key] = row
	
