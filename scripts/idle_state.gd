class_name IdleState extends State
## Idle State is the default state of the board state machine. From here,
## The machine can enter a series of states to handle moving jobs on the
## grid, or placing a pipe. The two series of states are mutually exclusive.
## This is also the starting point of the dragging deadline state,
## But that happens asynchronously from an external call.

## Reference board node to reduce overhead of repeated calls.
@onready var board_node := %Board as Board


## Transition to either pipe creation or job moving.
func update(_delta: float) -> void:
	if board_node.is_left_click_down: 
		transitioning.emit(self, "Holding Job")
	elif board_node.is_right_click_down:
		transitioning.emit(self, "Starting Pipe")

