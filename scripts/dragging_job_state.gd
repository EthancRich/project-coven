class_name DraggingJobState extends State

# Add more here?

func enter():
	print("Entering Dragging Job State")
	
func exit():
	print("Exiting Dragging Job State")
	
func update(_delta: float):
	if Input.is_action_just_released("click"):
		transitioning.emit(self, "Dropping Job")
	
