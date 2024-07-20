class_name DraggingJobState extends State
## DraggingJobState describes a job currently being dragged around
## on the board.

## Reference for board node to reduce the overhead of multiple calls.
@onready var board_node := %Board as Board


## Wait until the click is released, and then drop the job 
func update(_delta: float) -> void:
	if not board_node.is_left_click_down:
		transitioning.emit(self, "Dropping Job")
	
