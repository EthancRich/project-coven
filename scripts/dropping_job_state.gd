class_name DroppingJobState extends State

func enter():
	var board_node = %Board
	var hovered_cell = board_node.get_current_hovered_cell()
	if !(hovered_cell is Cell):
		print("Cannot Drop: Cannot find cell being hovered over")
		transitioning.emit(self, "Idle")
		return
		
	var focused_object = get_tree().get_first_node_in_group("focused")
	if !(focused_object is Job):
		print("Cannot Drop: Focused Object isn't Job (may be null?)")
		transitioning.emit(self, "Idle")
		return
	
	var segment = board_node.focused_job_segment
	var drop_index = hovered_cell.index
	print(drop_index)
	var first_index = Vector2i(drop_index.x - segment, drop_index.y)
	print(first_index)
	var possible_hovering_cells = get_hovering_cells(focused_object, first_index)
	if possible_hovering_cells == null:
		print("Cannot Drop: cells required are out of bounds")
		transitioning.emit(self, "Idle")
		return
	
	var hovering_cells: Array[Cell] = possible_hovering_cells
	if is_legal_drop(hovering_cells):
		move(focused_object, hovering_cells, first_index)
	
	transitioning.emit(self, "Idle")
	
	
func exit():
	%Board.remove_focused_object() #TODO: Set to a signal for Board to modify


func is_legal_drop(hovering_cells_array):
	for cell in hovering_cells_array:
		if cell.is_occupied():
			print("Cannot Drop: Hovered cell is occupied")
			return false	
	return true
	
	
func get_hovering_cells(focused_object:Job, first_index: Vector2i):
	var cells_array: Array[Cell] = []
	for i in range(focused_object.size):
		var index = Vector2i(first_index.x + i, first_index.y)
		if %Grid.is_out_of_bounds(index):
			print("GET_HOVERING_CELLS: index out of bounds")
			return null
		cells_array.push_back(%Grid.get_cell_at_index(index))
	return cells_array
	
	
func move(job: Job, cells_array: Array[Cell], first_index: Vector2i):
	print("MOVING JOB...")
	print("Job's current cells:")
	job.print_cells()	
	job.global_position = %Grid.indexToPixels(first_index)
	print("Deleting references to job in old cell(s)")
	job.disconnect_current_cells()
	print("Assigning new cells to job")
	job.current_cells = cells_array
	print("Printing new cells")
	job.print_cells()
	print("Adding new references to job in new cell(s)")
	job.connect_current_cells()
	
