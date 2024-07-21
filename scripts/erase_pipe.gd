class_name ErasePipeState extends State

@onready var staging_node: Node = %Staging

func enter():
	var pipe := get_tree().get_first_node_in_group("active_pipe") as Pipe
	if not pipe:
		if Global.DEBUG_MODE:
			push_error(self.name, " [enter]", " There is no pipe to delete from.")
		transitioning.emit(self, "Abandoning Pipe")
	var pipe_indexes := pipe.pipe_indexes
	
	if pipe_indexes.size() == 1: # Erasing the first pipe piece
		print("OPTION 1")
		transitioning.emit(self, "Abandoning Pipe")
		return
	
	# Traverse each pipe piece backward, deleting until hitting the marker
	#var pieces := pipe.get_children()
	#for i in range(pipe_indexes.size() - 1, -1, -1):
	while pipe.get_children().size() > 0:	
		var pipe_piece := pipe.get_children().back() as PipePiece
		if not pipe_piece:
			continue
		print("looping")
		if pipe_piece.delete_marker:
			print("OPTION 2")
			pipe_piece.delete_marker = false
			transitioning.emit(self, "Continuing Pipe")
			return
		pipe.erase_recent_pipe_piece()
		print("erasing pipe piece")
	
	# At this point, every pipe piece was deleted because no marker was set
	print("OPTION 3")
	transitioning.emit(self, "Abandoning Pipe")	
		
	
func exit():
	pass
	
func update(_delta: float):
	pass
