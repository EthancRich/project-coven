class_name Pipe extends Node2D
## Pipe is a parent to multiple pipe pieces, each
## of which occupies a single square on the grid.

## Rightmost job cell that the pipe is attached to.
var starting_job_cell: Cell

## An ordered list of pipe piece index references
var pipe_indexes: Array[Vector2i]

## The most recently placed pipe piece index
## NOTE: If there is no last piece, then the value is (-1, -1)
var last_piece_index := Vector2i(-1, -1)

## Grid node reference to reduce overhead in repeated calls
@onready var grid_node := get_node("/root/Main/Board/Grid") as Grid


## Assigns a provided cell to the starting job variable
func set_starting_job_cell(cell: Cell) -> void:
	starting_job_cell = cell
	
	
## Updates the last pipe piece index based on the index array
func update_last_piece_index() -> void:
	if pipe_indexes.size() > 0:
		last_piece_index = pipe_indexes.back() as Vector2i
	else:
		last_piece_index = Vector2i(-1, -1)


## Pushes an index to the back of the array, newest piece
func add_pipe_index(index: Vector2i) -> void:
	pipe_indexes.push_back(index)
	update_last_piece_index()


## Removes the last piece of the pipe and deletes it
func erase_recent_pipe_piece() -> void:
	pipe_indexes.pop_back()
	get_child(-1).queue_free()
	update_last_piece_index()


## Returns an array (x,y) of valid grid index pairs that represent the
## N/E/S/W directions surrounding "pipe's end", excluding out of bounds.
## NOTE: Will return no pairs if there is no pipe piece indexes in array
func get_possible_cell_indexes() -> Array[Vector2i]:
	
	# Check to make sure there is at least one pipe piece
	if pipe_indexes.size() == 0:
		if Global.DEBUG_MODE:
			push_error(self.name, " [get_possible_cell_indexes]", " No pipe piece to reference.")
		return []
	
	var temp_array: Array[Vector2i] = []
	var index_array: Array[Vector2i] = []
	
	# Put all possible index directions into a temporary array
	temp_array.push_back(Vector2i(last_piece_index.x-1, last_piece_index.y))
	temp_array.push_back(Vector2i(last_piece_index.x, last_piece_index.y-1))
	temp_array.push_back(Vector2i(last_piece_index.x+1, last_piece_index.y))
	temp_array.push_back(Vector2i(last_piece_index.x, last_piece_index.y+1))
	
	# Return an array of all valid indexess
	for index in temp_array:
		if not grid_node.is_index_out_of_bounds(index):
			index_array.push_back(index)
			
	return index_array


## Returns the (x,y) grid index of the previous previous pipe piece
## Returns (-1, -1) if no index can be found
func get_pprev_index() -> Vector2i:
	if pipe_indexes.size() > 1: # At least two pipe pieces
		return pipe_indexes[-2]
	elif pipe_indexes.size() == 1: # Two cells back is the starting point
		return starting_job_cell.index
	else:
		if Global.DEBUG_MODE:
			push_error(self.name, " [get_pprev_index]", " No pipe pieces found.")
		return Vector2i(-1, -1)
		

## alternative to reparent for pipes, this makes sure that the pipe pieces
## don't lose their cell pointers in the event that they are reparented.
## always use this function instead of reparent.
func reparent_pipe(new_parent: Node) -> void:
	
	## Get all children, set reparenting flag
	for child in get_children():
		var piece := child as PipePiece
		if not piece:
			continue
		piece.is_reparenting = true
	
	## Reparent the pipe
	self.reparent(new_parent)
	
	## Get all children, remove reparenting flag
	for child in get_children():
		var piece := child as PipePiece
		if not piece:
			continue
		piece.is_reparenting = false
	

## This function goes back and retroactively changes the
## sprites of pipe pieces after addititional contextual
## information is provided to adjust the accurate sprite.
func update_pipe_sprites() -> void:
	
	# Too few indexes to make adjustments, simply exit
	if pipe_indexes.size() <= 1:
		return
		
	# Make sure the pipe has the correct children count as well
	var children := get_children()
	if children.size() <= 1:
		if Global.DEBUG_MODE:
			push_error(self.name, " [update_pipe_sprites]", " Mistmatch in pipe index counts and children counts.")
		return
	
	const VEC_RIGHT := Vector2i(1, 0)
	const VEC_DOWN := Vector2i(0, 1)
	const VEC_UP := Vector2i(0, -1)
	var changing_piece := children[-2] as PipePiece
	var last_diff: Vector2i
	var animation_string: String
	
	# If there's only two pipe pieces, then assume right was last diff
	if pipe_indexes.size() == 2:
		last_diff = Vector2i(1, 0)
	# Otherwise, consider pprev and prev indexes
	elif pipe_indexes.size() > 2:
		last_diff = pipe_indexes[-2] - pipe_indexes[-3]
	
	# Get the current difference to obtain a direction
	var current_diff := pipe_indexes[-1] - pipe_indexes[-2]
	
	print(last_diff, current_diff)
	
	match last_diff:
		VEC_RIGHT: 
			if current_diff == VEC_RIGHT:
				return
			elif current_diff == VEC_UP:
				animation_string = "pipe4"
			elif current_diff == VEC_DOWN:
				animation_string = "pipe3"
		VEC_UP:
			if current_diff == VEC_RIGHT:
				animation_string = "pipe5"
			elif current_diff == VEC_UP:
				return	
		VEC_DOWN:
			if current_diff == VEC_RIGHT:
				animation_string = "pipe6"
			elif current_diff == VEC_DOWN:
				return
		_:
			print("Something bad happened")
			return
		
	# No change occurs, then just return
	if animation_string == "":
		return
	
	changing_piece.update_sprite(animation_string)
