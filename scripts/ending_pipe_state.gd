class_name EndingPipeState extends State

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
		# Move the pipe from staging into grid
		get_active_pipe().reparent(grid_node)
		transitioning.emit(self, "Idle")

func _on_board_changed_mouse_cell(_prev_cell_index, current_cell_index):
	if !active_state:
		return
		
	# Check for regressing backwards to go back to the last states
	var pipe = get_active_pipe()
	var possible_locations = pipe.get_possible_cell_indexes()
	print(possible_locations)
	if !current_cell_in_locations(current_cell_index, possible_locations):
		print("Could not find", current_cell_index, "in", possible_locations)
		return
	# At this point, the player is hovering over N/E/S/W of last pipe piece
	
	# The player moved back to their previous cell
	if pipe.get_pprev_index() == current_cell_index:
		print("MOVED BACK INTO ORIGINAL CELL")
		transitioning.emit(self, "Erasing Pipe")
		return


func get_active_pipe():
	for child in staging_node.get_children():
		if child is Pipe:
			return child
			
			
func current_cell_in_locations(cell_index: Vector2i, locations: Array):
	for index in locations:
		if cell_index == index:
			return true
	return false
