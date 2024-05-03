@icon("res://addons/utility_ai/utility_task.svg")
extends Resource
class_name UtilityTask # Base class for all Utility AI tasks
var task_name: String = "UtilityTask" # Unique name given to this task

# The root node of the NPC scene
var npc_node: Node
# The Utility Task Manager attached to the NPC
var task_manager: UtilityTaskManager
# In-game msecs timestamp updated each time _start() is called
var time_of_last_start: int = 0

# Called when NPC spawns
# @param npc_node - The topmost node of the NPC scene. Usually a kinematic body
# @param task_manager - Reference to the UtilityTaskManager running on the NPC
func _construct(_npc_node, _task_manager):
	npc_node = _npc_node
	task_manager = _task_manager

# Rates this task from 0-1, based on environmental factors
func _score():
	return -1

# Called when NPC begins this task
func _start():
	time_of_last_start = Time.get_ticks_msec()
	pass

# Called before NPC begins new task. Must be synchronous, as task will no longer be active next frame. Must not interact with the UtilityTaskManager.
func _cancel():
	pass

# Tasks may only resume from a yield if they are still the active task, and if the related NPC is still valid
func _cant_resume():
	var can_resume = is_instance_valid(npc_node) && is_instance_valid(task_manager) && task_manager.active_task == self
	return !can_resume
