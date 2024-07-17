class_name DraggingJobState extends State

func enter():
	pass
	
func exit():
	pass
	
func update(_delta: float):
	if !%Board.is_left_click_down:
		transitioning.emit(self, "Dropping Job")
	
