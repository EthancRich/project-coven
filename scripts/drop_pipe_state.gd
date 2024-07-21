class_name DropPipeState extends State
## This state places a pipe piece at the current position.

## board node reference to reduce overhead of multiple calls.
@onready var board_node := %Board as Board

## staging node reference to reduce overhead of multiple calls.
@onready var staging_node := %Staging as Node

## PackedScene of pipe pieces to instantiate
var pipe_piece_scene: PackedScene = preload("res://scenes/pipe_piece.tscn")


## Upon entry, drop a pipe and then transition
func enter() -> void:
	
	# Obtain indexes of current cell
	var current_cell := board_node.get_current_hovered_cell()
	if not current_cell:
		if Global.DEBUG_MODE:
			push_error(self.name, " [enter]", "Cannot drop pipe, a cell is out of bounds.")
		transitioning.emit(self, "Abandoning Pipe")
		return
	var current_cell_index := current_cell.index
		
	# Create a pipe piece
	var pipe_piece := pipe_piece_scene.instantiate() as PipePiece
	pipe_piece.pipe = get_tree().get_first_node_in_group("active_pipe") as Pipe
	pipe_piece.global_position = current_cell.global_position
	pipe_piece.initialize_orientation(current_cell_index)
	
	# Relate the cell and the pipe piece with each other
	pipe_piece.current_cell = current_cell
	current_cell.set_contained_object(pipe_piece)
	
	# Attempt to add the pipe piece to the pipe parent object
	if pipe_piece.add_piece_to_pipe():
		transitioning.emit(self, "Continuing Pipe")
	else:
		transitioning.emit(self, "Abandoning Pipe")


## Attempts to add pipe piece to pipe. Returns true if successful,
## or false otherwise.
## TODO: Move into the Pipe Piece script
#func try_add_piece_to_pipe(pipe_piece: PipePiece) -> bool:
	#for child in staging_node.get_children():
		#if child is Pipe:
			#var pipe := child as Pipe
			#pipe.add_child(pipe_piece)
			#pipe.add_pipe_index(pipe_piece.current_cell.index)
			#return true
			#
	#if Global.DEBUG_MODE:
		#push_error(self.name, " [try_add_piece_to_pipe]", " no pipe parent to attach to.")
	#return false
