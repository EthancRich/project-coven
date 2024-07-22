class_name HoldingState extends State
## This state represents the player holding down left
## click, but before the drag operation has engaged. This
## script holds the logic to determine when to transition
## to a drag move of the job.

## Reference node to reduce overhead of repeated calls.
@onready var board_node := %Board as Board 

## Flag to represent if the player has moved cells before drag engaged.
var moved_cells: bool = false

## The amount of time left click has been held down
var elapsed_time: float = 0.0


## Reset the values upon entering the state
func enter(_args: Array) -> void:
	moved_cells = false
	elapsed_time = 0.0
	

## Logically determine whether to move the player to Idle or Drag
func update(delta: float) -> void:
	
	# Player has moved to a different cell during the drag before completion
	if moved_cells:
		if not board_node.is_left_click_down: # Click released, can return to Idle
			transitioning.emit(self, "Idle")
		else:	# Otherwise, keep them trapped in this state until released
			pass
			
	# Player remains in the current cell where it was started
	else:
		if not board_node.is_left_click_down: # Click released, can return to Idle
			transitioning.emit(self, "Idle")
		else:
			elapsed_time += delta
			if elapsed_time > board_node.longpress_time:
				transitioning.emit(self, "Dragging Job")


## Updates flag for moved cells.
## NOTE: Active even when off state, but reset before entering.
func _on_board_changed_mouse_cell(_prev_cell_index: Vector2i, _current_cell_index: Vector2i) -> void:
	moved_cells = true
