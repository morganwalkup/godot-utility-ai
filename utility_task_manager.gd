@icon("res://addons/utility_ai/utility_task_manager.svg")
extends Node
# Utility AI decision-making brain for NPCs. Must be a child of the topmost NPC node
class_name UtilityTaskManager

# The task scripts to choose from, added through the editor
@export var utility_task_scripts: Array[Script] = []
# The task instances to choose from, generated on _ready()
var utility_tasks: Array[UtilityTask] = []
# The previously chosen task. Initializes to utility_tasks[0]
var previous_task: UtilityTask
# The currently chosen task. Initializes to utility_tasks[0]
var active_task: UtilityTask
# How frequently we choose a task to perform
@export var decision_frequency_ms: float = 500.0
# Timer that triggers decisions
var _decision_timer: Timer
# If true, decisions will be made every frame instead of using decision_frequency_ms
@export var replace_timer_with_process: bool = false
# True if an interrupt has been triggered but the new task hasn't been started yet
var pending_interrupt: bool = false
# Topmost node of NPC. Root of the NPC scene.
@onready var npc_node: Node = get_parent()

# A psuedo-timer that times out every frame
class ProcessTimer extends Timer:
	var _stopped = true
	func start(_time_sec = -1.0):
		_stopped = false
	func stop():
		_stopped = true
	func is_stopped():
		return _stopped
	func _process(_delta):
		if !_stopped: emit_signal("timeout")

# Called when the node enters the scene tree for the first time.
func _ready():
	_init_timer()
	_init_tasks()

# Constructs utility task instances and immediately starts the FIRST task in the array
func _init_tasks():
	# Create task instances
	for task_script in utility_task_scripts:
		var utility_task = UtilityTask.new()
		utility_task.set_script(task_script)
		utility_tasks.append(utility_task)
	# Initialize task instances		
	for task in utility_tasks:
		task._construct(npc_node, self)
	previous_task = utility_tasks[0]
	active_task = utility_tasks[0]
	active_task._start()

func _decide_task():
	var top_score = 0
	previous_task = active_task
	for task in utility_tasks:
		var score = task._score()
		if score > top_score:
			top_score = score
			active_task = task
	if (previous_task != active_task):
		previous_task._cancel()
		active_task._start()

func _handle_decision_timeout():
	_decide_task()

func _init_timer():
	if (replace_timer_with_process):
		_decision_timer = ProcessTimer.new()
	else:
		_decision_timer = Timer.new()
		_decision_timer.wait_time = decision_frequency_ms / 1000.0
	add_child(_decision_timer)
	_decision_timer.timeout.connect(_handle_decision_timeout)
	_decision_timer.start()

func pause_decision_timer():
	_decision_timer.stop()

func resume_decision_timer(immediate = false):
	_decision_timer.start()
	if (immediate && !pending_interrupt): _decide_task()

func _process(delta):
	if (active_task && active_task.has_method("_process")):
		active_task._process(delta)

func _physics_process(delta):
	if (active_task && active_task.has_method("_physics_process")):
		active_task._physics_process(delta)

func interrupt(task_name):
	var new_task = null
	for task in utility_tasks:
		if task_name == task.task_name:
			new_task = task
	if new_task:
		previous_task = active_task
		active_task = new_task
		if (previous_task != active_task):
			pending_interrupt = true
			previous_task._cancel()
			active_task._start()
			pending_interrupt = false
	else:
		print("UtilityTaskManager interrupt could not find ", task_name)

func get_task(task_name):
	for task in utility_tasks:
		if task_name in task.resource_path || ("task_name" in task && task_name in task.task_name):
			return task
	return null