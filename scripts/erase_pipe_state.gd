class_name ErasePipeState extends State
## ErasePipeState erasese pipe pieces. The number of pieces depends
## on whether the enter call provided a piece to end with. The default
## operation is to delete a single piece.


## Action to take upon entering.
func enter(args: Array):
	
	# Obtain the pipe indexes
	var pipe := get_tree().get_first_node_in_group("active_pipe") as Pipe
	if not pipe:
		if Global.DEBUG_MODE:
			push_error(self.name, " [enter]", " There is no pipe to delete from.")
		transitioning.emit(self, "Abandoning Pipe")
	var pipe_indexes := pipe.pipe_indexes
	
	# TODO: Consider if this is necessary to stay
	# NOTE: This references size of index to 1, so this must change with changes to the array]
	# Abandon pipe if the player moves back into the starting cell
	if args.size() > 0 and args[0] is Vector2i and args[0] == pipe.starting_job_cell.index:
		print("OPTION 1a: Calling erase when moving back into first job cell")
		transitioning.emit(self, "Abandoning Pipe")
		return
	elif pipe_indexes.size() == 1: # Erasing the first pipe piece
		print("OPTION 1b: Calling erase when moving back into first job cell")
		transitioning.emit(self, "Abandoning Pipe")
		return

	# At this point, not abandoning pipe, just deleting some number of pieces
	
	if args.size() > 0 and args[0] is Vector2i:
		
		# Delete all pieces until that cell is hit
		print("OPTION 2: Deleting until the given cell is reached")
		var current_index := args[0] as Vector2i
		while (current_index != pipe.last_piece_index):
			pipe.erase_recent_pipe_piece()
			print("deleted piece")
	else:
		# Delete only a single piece, because no amount was specified
		print("OPTION 3: Delete a single piece, no count was specified")
		pipe.erase_recent_pipe_piece()

	transitioning.emit(self, "Continuing Pipe")
