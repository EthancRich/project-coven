class_name AbandonPipeState extends State
## This state is used to remove the parent pipe object and all its children. 
## After it's completed, the state machine will return to idle.

## staging node reference to reduce overhead in repeated calls.
@onready var staging_node := %Staging as Node


## Upon enter, delete the pipe and return to Idle state.
## NOTE: Making the assumption that only one child of the staging node
func enter() -> void:
	var pipe := staging_node.get_child(0) as Pipe
	if not pipe:
		if Global.DEBUG_MODE:
			push_warning(self.name, " [enter]", " No pipe to delete.")
	else:
		pipe.queue_free()
		
	transitioning.emit(self, "Idle")
