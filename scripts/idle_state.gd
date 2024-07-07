class_name IdleState extends State

func enter():
	pass
	
func exit():
	pass
	
func update(_delta: float):
	# If the click button is held down, then increase time and potentially drag
	if %Board.is_click_down: #TODO: Omit areas of the screen that have UI elements
		transitioning.emit(self, "Holding Job")

