class_name AbandonPipeState extends State

@onready var staging_node := %Staging as Node

# Assumption: only one child of the staging node
func enter():
	var pipe = staging_node.get_child(0)
	if pipe == null:
		print("ABANDON PIPE: No pipe found to abandon.")
		
	pipe.queue_free()
	transitioning.emit(self, "Idle")
	
func exit():
	pass
	
func update(_delta: float):
	pass
