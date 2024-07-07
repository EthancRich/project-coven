class_name HoldingState extends State

# Instance Variables
var board_node: Board 	# Less repeated accesses of the same node
var moved_cells: bool
var elapsed_time: float


func _ready():
	board_node = %Board
	moved_cells = false
	elapsed_time = 0.0

func enter():
	moved_cells = false
	elapsed_time = 0.0
	
func exit():
	pass
	
func update(delta: float):
	
	# Player has moved to a different cell during the drag before completion
	if moved_cells:
		if !board_node.is_click_down: # Click released, can return to Idle
			transitioning.emit(self, "Idle")
		else:	# Otherwise, keep them trapped in this state until released
			pass
			
	# Player remains in the current cell where it was started
	else:
		if !board_node.is_click_down: # Click released, can return to Idle
			transitioning.emit(self, "Idle")
		else:
			elapsed_time += delta
			if elapsed_time > board_node.longpress_time:
				transitioning.emit(self, "Dragging Job")


func _on_board_changed_mouse_cell():
	moved_cells = true
