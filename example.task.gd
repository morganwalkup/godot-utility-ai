extends UtilityTask
# Example task for the Utility AI plugin. Implements the basic UtilityTask.

func _construct(_npc_node, _task_manager):
    super(_npc_node, _task_manager)
    task_name = "Example"
    print("Example task constructed")

func _score():
    print("Example task score")
    return 1.0

func _start():
    print("Example task start")

func _cancel():
    print("Example task cancel")





