class_name IdleState extends State

# Things to add?

func enter():
	print("Entering Idle State")
	
func exit():
	print("Exiting Idle State")
	
func update(_delta: float):
	pass

func _on_default_job_dragging():
	transitioning.emit(self, "Dragging Job")
