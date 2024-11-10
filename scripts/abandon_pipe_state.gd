class_name AbandonPipeState extends State
## This state is used to remove the parent pipe object and all its children. 
## After it's completed, the state machine will return to idle.

## staging node reference to reduce overhead in repeated calls.
@onready var board_node := %Board as Board

 
## Upon enter, delete the pipe and return to Idle state.
func enter(_args: Array) -> void:
	var pipe := get_tree().get_first_node_in_group("active_pipe") as Pipe
	if not pipe:
		if Global.DEBUG_MODE:
			push_warning(self.name, " [enter]", " No pipe to delete.")
	else:
		pipe.delete()
		board_node.remove_active_pipe()
		
	transitioning.emit(self, "Idle")
