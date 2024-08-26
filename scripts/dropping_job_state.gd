class_name DroppingJobState extends State
## DroppingJobState attempts to relocate the currently held
## job to the dropped location, or abandons the movement if
## the location is invalid.

## Signal that tells the GUI Dropper to potentially delete the job it created
signal dropped

## Reference for board node to reduce overhead in repeated calls.
@onready var board_node := %Board as Board

## Reference for grid node to reduce overhead in repeated calls.
@onready var grid_node := %Grid as Grid



## On entry, attempt to move job if all checks pass
## NOTE: args == [current_cell_index: Vector2i]
func enter(args: Array) -> void:
	
	# Obtain the cell the player is dropping onto
	var hovered_cell: Cell
	if args.size() > 0 and args[0] is Vector2i:
		var current_cell_index := args[0] as Vector2i
		hovered_cell = grid_node.get_cell_at_index(current_cell_index)
	else:
		hovered_cell = board_node.get_current_hovered_cell()
		if Global.DEBUG_MODE:
			push_warning(self.name, " [enter]", " index not provided, getting cell from board state")
		
	if not hovered_cell:
		if Global.DEBUG_MODE:
			push_error(self.name, " [enter]", " hovered cell is null.")
		transitioning.emit(self, "Idle")
		return
		
	# NOTE: Assuming that there is only one focused object, getting the first
	var focused_job := get_tree().get_first_node_in_group("focused") as Job
	if not focused_job:
		if Global.DEBUG_MODE:
			push_warning(self.name, " [enter]", " focused object is not job or null.")
		transitioning.emit(self, "Idle")
		return
	
	var segment := board_node.focused_job_segment
	var drop_index := hovered_cell.index
	var first_index := Vector2i(drop_index.x - segment, drop_index.y)
	if is_legal_drop(focused_job, first_index):
		move(focused_job, first_index)
		dropped.emit(true, focused_job)
	else:
		dropped.emit(false, focused_job)
	
	# TODO: Set to a signal for Board to modify after completion
	board_node.remove_focused_object()
	transitioning.emit(self, "Idle")


## returns true if the drop location has all required cells in bounds and empty.
func is_legal_drop(focused_job: Job, first_index: Vector2i) -> bool:
	
	# Get all cells that the new job will occupy after moving
	var hovering_cells_array := get_hovering_cells(focused_job, first_index)
	if hovering_cells_array.is_empty():
		if Global.DEBUG_MODE:
			print(self.name, " [is_legal_drop]", "Aborting drop: cells required are out of bounds.")
		return false
	
	# Confirm that no cell is occupied
	for cell in hovering_cells_array:
		if cell.is_occupied() and (cell.contained_object != focused_job):
			if Global.DEBUG_MODE:
				print(self.name, " [is_legal_drop]", "Aborting drop: required cell is occupied.")
			return false	
			
	return true
	
	
## Returns an array of cell objects that the focused job will occupy when
## moved to the first index.
## If any of the cells necessary areout of bounds, then return a null array.
func get_hovering_cells(focused_object: Job, first_index: Vector2i) -> Array[Cell]:
	var cells_array: Array[Cell] = []
	
	for i in range(focused_object.size):
		var index := Vector2i(first_index.x + i, first_index.y)
		if grid_node.is_index_out_of_bounds(index):
			if Global.DEBUG_MODE:
				push_warning(self.name, " [get_hovering_cells]", " necessary cell is out of bounds: ", index)
			return []
		cells_array.push_back(grid_node.get_cell_at_index(index))
		
	return cells_array
	
	
## Moves the job to start at the provided first index.
## NOTE: This is not a safe function; requires legal check first.
func move(job: Job, first_index: Vector2i) -> void:
	
	# Move the job into new position
	job.global_position = grid_node.index_to_pixels(first_index)
	
	# Adjust pointers between cells and job
	var cells_array := get_hovering_cells(job, first_index)	
	job.disconnect_current_cells()
	job.current_cells = cells_array
	job.connect_current_cells()
	
	# Update the locations of the witches attached to job
	job.update_witch_locations()
	
