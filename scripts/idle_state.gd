class_name IdleState extends State

var current_longpress_time: float

func enter():
	print("Entering Idle State")
	current_longpress_time = 0.0
	
func exit():
	print("Exiting Idle State")
	current_longpress_time = 0.0
	
func update(delta: float):
	# If the click button is held down, then increase time and potentially drag
	if %Board.is_click_down: #TODO: Omit areas of the screen that have UI elements
		current_longpress_time += delta
		if current_longpress_time > %Board.longpress_time:
			transitioning.emit(self, "Dragging Job")
	else:
		current_longpress_time = 0.0
	
func _on_board_changed_mouse_cell():
	current_longpress_time = 0.0
	print("resetting timer because new cell!")
