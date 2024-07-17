class_name ErasePipeState extends State

@onready var staging_node: Node = %Staging

func enter():
	var pipe = get_active_pipe()
	if pipe.pipe_indexes.size() == 1: # Erasing the first pipe
		transitioning.emit(self, "Abandoning Pipe")
		return
		
	if pipe.pipe_indexes.size() > 1: # Erasing the last laid pipe
		pipe.erase_recent_pipe_piece()
		transitioning.emit(self, "Continuing Pipe")
	
func exit():
	pass
	
func update(_delta: float):
	pass

func get_active_pipe():
	for child in staging_node.get_children():
		if child is Pipe:
			return child
