class_name ErasePipeState extends State
## ErasePipeState erasese pipe pieces. The number of pieces depends
## on whether the enter call provided a piece to end with. The default
## operation is to delete a single piece.

## Signal for pipe sounds
signal pipe_piece_erased

## Action to take upon entering.
func enter(args: Array):
	
	# Delete pipe piece sound
	pipe_piece_erased.emit()
	
	# Obtain the pipe indexes
	var pipe := get_tree().get_first_node_in_group("active_pipe") as Pipe
	if not pipe:
		if Global.DEBUG_MODE:
			push_error(self.name, " [enter]", " There is no pipe to delete from.")
		transitioning.emit(self, "Abandoning Pipe")
	var pipe_indexes := pipe.pipe_indexes
	
	# Abandon pipe if the player moves back into the starting cell
	if args.size() > 0 and args[0] is Vector2i and args[0] == pipe.pipe_indexes[0]:
		transitioning.emit(self, "Abandoning Pipe")
		return
	elif pipe_indexes.size() <= 2: # Erasing the first pipe piece
		transitioning.emit(self, "Abandoning Pipe")
		return
	# At this point, not abandoning pipe, just deleting some (not all) pieces
	
	# If cell specified, delete all pieces until that cell is hit
	if args.size() > 0 and args[0] is Vector2i:
		var current_index := args[0] as Vector2i
		while (current_index != pipe.last_piece_index):
			pipe.erase_recent_pipe_piece()
	# Otherwise no amount was specified, delete a single cell	
	else:
		pipe.erase_recent_pipe_piece()

	transitioning.emit(self, "Continuing Pipe")
