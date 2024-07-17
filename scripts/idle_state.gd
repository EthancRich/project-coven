class_name IdleState extends State

@onready var board_node: Board = %Board

func enter():
	pass
	
func exit():
	pass
	
func update(_delta: float):
	# If the click button is held down, then increase time and potentially drag
	if board_node.is_left_click_down: #TODO: Omit areas of the screen that have UI elements
		transitioning.emit(self, "Holding Job")
	elif board_node.is_right_click_down:
		transitioning.emit(self, "Starting Pipe")

