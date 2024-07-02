class_name DraggingJobState extends State

func enter():
	print("Entering Dragging Job State")
	
func exit():
	print("Exiting Dragging Job State")
	
func update(_delta: float):
	if !%Board.is_click_down:
		transitioning.emit(self, "Dropping Job")
	
