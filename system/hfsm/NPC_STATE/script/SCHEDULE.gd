extends HFSM_STATE

enum _JOB {
	GUARD,
}

@export_category("GENERAL INFO")
@export var home := ""

@export_category("TASK")
@export var task00 : Res_Schedule_Task
@export var task01 : Res_Schedule_Task
@export var task02 : Res_Schedule_Task
@export var task03 : Res_Schedule_Task
@export var task04 : Res_Schedule_Task
@export var task05 : Res_Schedule_Task
@export var task06 : Res_Schedule_Task
@export var task07 : Res_Schedule_Task
@export var task08 : Res_Schedule_Task
@export var task09 : Res_Schedule_Task
@export var task10 : Res_Schedule_Task
@export var task11 : Res_Schedule_Task
@export var task12 : Res_Schedule_Task
@export var task13 : Res_Schedule_Task
@export var task14 : Res_Schedule_Task
@export var task15 : Res_Schedule_Task
@export var task16 : Res_Schedule_Task
@export var task17 : Res_Schedule_Task
@export var task18 : Res_Schedule_Task
@export var task19 : Res_Schedule_Task
@export var task20 : Res_Schedule_Task
@export var task21 : Res_Schedule_Task
@export var task22 : Res_Schedule_Task
@export var task23 : Res_Schedule_Task

var schedule := []

var running_schedule : Res_Schedule_Task

func entering():
	
	GameState.statistics["schedule_home"] = home
	#GameState.date_changed.connect(date_changed())# .connect(Callable(self, "date_changed"))
	#GameState.hour_changed.connect(hour_changed())# Callable(self, "hour_changed"))
	
	if schedule.is_empty():
		generate_schedule()
		
	running_schedule = schedule[GameState.statistics["hour"]]
	change_child_state()
	
func working(_delta):
	pass
	
func exiting():
	GameState.date_changed.disconnect(date_changed())
	GameState.hour_changed.disconnect(hour_changed())

func hour_changed():
	if running_schedule != schedule[GameState.statistics["hour"]]:
		running_schedule = schedule[GameState.statistics["hour"]]
		change_child_state()
	
func date_changed():
	pass
	
func change_child_state():
	state_next = "GOTO_SCHEDULE_LOCATION"
	GameState.statistics["schedule_location"] = home
	
func generate_schedule():
	#change_schedule
	schedule = []
	if not task00:
		task00 = Res_Schedule_Task.new()
	schedule.append(task00)
	schedule = append_task(schedule, task01)
	schedule = append_task(schedule, task02)
	schedule = append_task(schedule, task03)
	schedule = append_task(schedule, task04)
	schedule = append_task(schedule, task05)
	schedule = append_task(schedule, task06)
	schedule = append_task(schedule, task07)
	schedule = append_task(schedule, task08)
	schedule = append_task(schedule, task09)
	schedule = append_task(schedule, task10)
	schedule = append_task(schedule, task11)
	schedule = append_task(schedule, task12)
	schedule = append_task(schedule, task13)
	schedule = append_task(schedule, task14)
	schedule = append_task(schedule, task15)
	schedule = append_task(schedule, task16)
	schedule = append_task(schedule, task17)
	schedule = append_task(schedule, task18)
	schedule = append_task(schedule, task19)
	schedule = append_task(schedule, task20)
	schedule = append_task(schedule, task21)
	schedule = append_task(schedule, task22)
	schedule = append_task(schedule, task23)
	
func append_task(arr, task):
	if task:
		arr.append(task)
	else:
		arr.append(arr[arr.size()-1])
	return arr
	
