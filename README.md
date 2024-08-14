# Utility AI 🤖💭

A decision-making 'brain' for video game characters, powered by utility scores.

Production tested! This is the system I use in my own game, [Code Zodiac](https://store.steampowered.com/app/2403880/Code_Zodiac/)

### How to Use

1. Add this code to your `addons/` folder
1. Go to `Project > Project Settings > Plugins` to enable the plugin
1. Open your NPC scene and add a `UtilityTaskManager` node just below the root
1. (Optional) Create a specialized `npc_task.gd` script with a `NPCTask` class that extends from `UtilityTask`. See `example.task.gd` for details.
1. Create a `some_action.task.gd` script that extends from `NPCTask`. See `example.task.gd` for details.
1. Drag `some_action.task.gd` to the `UtilityTaskManager` array of `utility_task_scripts`

### UtilityTask

The `UtilityTask` base class describes a task to be performed by some character.

### Properties

- task_name - String - A unique name for this task. Should be set in the _construct() function
- task_manager - UtilityTaskManager - The utility task manager attached to the NPC
- npc_node - Node - Root node of the NPC scene
- time_of_last_start - int - In-game msecs timestamp updated each time _start() is called

### Lifecycle Methods

These methods are called by the UtilityTaskManager as it scores and performs tasks:
- _construct(_npc_node, _task_manager) - void - Called when NPC spawns
- _score() - float - Rates the task (usually from 0.0 to 1.0), based on environmental factors
- _start() - void - Called when the NPC begins this task
- _cancel() - void - Called before the NPC begins a new task. Must be synchronous. Must not reference task_manager.
- _cant_resume() - bool - Useful function to call when returning from an await. Returns true if the task is invalid and cannot be resumed.

### UtilityTaskManager

The `UtilityTaskManager` class scores a given array of tasks on some regular interval, and performs the highest-scoring task. **Must be a direct child of the NPC's root node**.

#### Properties

- utility_task_scripts - Array[Script] - The task scripts to choose from, added through the editor
- utility_tasks - Array[UtilityTask] - The task instances to choose from, generated on _ready()
- previous_task - UtilityTask - The previously chosen task. Initializes to utility_tasks[0]
- active_task - UtilityTask - The currently chosen task. Initializes to utility_tasks[0]
- decision_frequency_ms - float - How frequently we choose a task to perform
- replace_timer_with_process - bool - If true, decisions will be made every frame instead of using decision_frequency_ms
- pending_interrupt - bool - True if an interrupt has been triggered but the new task hasn't been started yet
- npc_node - Root node of the NPC. Topmost node of the NPC scene.

#### Public Methods

- pause_decision_timer() - void - Stops the decision timer until resume_decision_timer is called
- resume_decision_timer(immediate) - void - Resumes the decision timer. If `immediate` is true, it chooses the next task without waiting for the decision timer.
- interrupt(task_name) - void - Cancels the current task and starts the given task. If the new task is the same as the current task, nothing will happen.
- get_task(task_name) - UtilityTask | null - Returns the UtilityTask instance with the given task_name
