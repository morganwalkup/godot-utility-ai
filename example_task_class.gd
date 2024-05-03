# extends UtilityTask
# class_name ExampleTask
# # A specialized UtilityTask that stores references to common nodes within the character

# var character_body: CharacterBody2D
# var animated_sprite: AnimatedSprite2D
# var player_node: CharacterBody2D
# var hurtbox : Area2D

# func _construct(_npc_node, _task_manager):
# 	super(_npc_node, _task_manager)
# 	character_body = _npc_node
# 	animated_sprite = character_body.get_node("AnimatedSprite")
# 	hurtbox = character_body.get_node("Hurtbox")
# 	player_node = _npc_node.get_tree().get_nodes_in_group("Player")[0]