class_name DropPipeState extends State

@onready var board_node: Board = %Board
@onready var staging_node: Node = %Staging
var pipe_piece_scene: PackedScene = preload("res://scenes/pipe_piece.tscn")

func enter():
	var current_cell = board_node.get_current_hovered_cell()
	var prev_cell = board_node.get_prev_hovered_cell()
	var current_cell_index = current_cell.index
	var prev_cell_index = prev_cell.index
		
	# Create a pipe piece
	var pipe_piece = pipe_piece_scene.instantiate()
	pipe_piece.global_position = current_cell.global_position
	pipe_piece.initialize_orientation(current_cell_index, prev_cell_index)
	
	# Relate the cell and the pipe piece with each other
	pipe_piece.current_cell = current_cell
	current_cell.set_contained_object(pipe_piece)
	print(current_cell.contained_object)
	
	# Add the pipe piece to the pipe parent object
	if !add_pipe_piece_to_pipe(pipe_piece):
		print("Parent Pipe Object not found. Cannot add child pipe piece.")
	
	transitioning.emit(self, "Continuing Pipe")
	
func pipe_exists():
	for child in staging_node.get_children():
		if child is Pipe:
			return true
	return false

## TODO: Move into the Pipe Piece script
func add_pipe_piece_to_pipe(pipe_piece: PipePiece):
	for child in staging_node.get_children():
		if child is Pipe:
			child.add_child(pipe_piece)
			child.add_pipe_index(pipe_piece.current_cell.index)
			return true
	return false
	

	
	
