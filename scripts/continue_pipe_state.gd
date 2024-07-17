class_name ContinuePipeState extends State

@onready var board_node: Board = %Board
@onready var grid_node: Grid = %Grid
@onready var staging_node: Node = %Staging
var active_state = false

func enter():
	active_state = true
	
func exit():
	active_state = false

func update(_delta: float):
	if !board_node.is_right_click_down:
		transitioning.emit(self, "Abandoning Pipe")

# Do I even care about these stupid indexes here
func _on_board_changed_mouse_cell(_prev_cell_index, current_cell_index):
	
	if !active_state:
		return
	
	var pipe = get_active_pipe()
	var possible_locations = pipe.get_possible_cell_indexes()
	print(possible_locations)
	if !current_cell_in_locations(current_cell_index, possible_locations):
		print("Could not find", current_cell_index, "in", possible_locations)
		return
	# At this point, the player is hovering over N/E/S/W of last pipe piece
	
	# Option 1: The player moved back to their previous cell
	if pipe.get_pprev_index() == current_cell_index:
		print("MOVED BACK INTO ORIGINAL CELL")
		transitioning.emit(self, "Erasing Pipe")
		return
	
	# If the player is going left, then don't allow it
	if current_cell_index == possible_locations[0]:
		print("MOVED LEFT/WEST")
		return
	# Player at this point has moved N/E/S by 1 
	
	# Option 2: The player moved into a new job to end the pipe
	var current_cell = grid_node.get_cell_at_index(current_cell_index)
	if current_cell.contains_job():
		if current_cell.contained_object.current_cells[0] == current_cell:
			print("MOVED INTO FIRST CELL OF JOB")
			transitioning.emit(self, "Ending Pipe")
			return
	
	# Option 3: The player has moved into unoccupied square to drop pipe piece
	if !current_cell.is_occupied():
		transitioning.emit(self, "Dropping Pipe")
	
	
func current_cell_in_locations(cell_index: Vector2i, locations: Array):
	for index in locations:
		if cell_index == index:
			return true
	return false
	
# Assumes active pipe is the first Pipe child in Staging
func get_active_pipe():
	for child in staging_node.get_children():
		if child is Pipe:
			return child
