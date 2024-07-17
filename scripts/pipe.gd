class_name Pipe extends Node2D

var starting_job_cell: Cell
var pipe_indexes: Array[Vector2i]
@onready var grid_node: Grid = get_node("/root/Main/Board/Grid")

func set_starting_job_cell(cell: Cell):
	starting_job_cell = cell
	
func add_pipe_index(index: Vector2i):
	pipe_indexes.push_back(index)

func erase_recent_pipe_piece():
	pipe_indexes.pop_back()
	get_child(-1).queue_free()

# Returns N/E/S/W directions from the last pipe piece placed
func get_possible_cell_indexes():
	
	var last_piece_index = pipe_indexes.back()
	var temp_array = []
	var index_array = []
	temp_array.push_back(Vector2i(last_piece_index.x-1, last_piece_index.y))
	temp_array.push_back(Vector2i(last_piece_index.x, last_piece_index.y-1))
	temp_array.push_back(Vector2i(last_piece_index.x+1, last_piece_index.y))
	temp_array.push_back(Vector2i(last_piece_index.x, last_piece_index.y+1))
	
	for index in temp_array:
		if !grid_node.is_index_out_of_bounds(index):
			index_array.push_back(index)
			
	return index_array

	
func get_pprev_index():
	if pipe_indexes.size() > 1: # At least two pipe pieces
		return pipe_indexes[-2]
	elif pipe_indexes.size() == 1: # Two cells back is the starting point
		return starting_job_cell.index
	else:
		print("PIPE - GET_TWO_CELLS_BACK: no pipe pieces found, ERROR")
		return null
