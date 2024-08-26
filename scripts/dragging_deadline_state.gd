class_name DraggingDeadlineState extends State
## Dragging Deadline State script places the deadline into a dragging
## state, then wait until the player releases left click to set it.

## Reference for board node to reduce the overhead of multiple calls.
@onready var board_node := %Board as Board

## The deadline being considered while in this state
var current_deadline: Deadline = null


## enter function sets the deadline object for the state to modify
## args == [deadline: Deadline]
func enter(args: Array) -> void:
	
	# Assign the deadline object
	if args.size() > 0:
		current_deadline = args[0]
	
	# Check if current_deadline is null
	if not current_deadline:
		if Global.DEBUG_MODE:
			push_warning(self.name, " [enter]", " no Deadline object provided, defaulting to null")
	
	
## Reset the deadline variable to be null
func exit() -> void:
	current_deadline = null
	

## Keeps the deadline locked in drag state until left click is lifted.
func update(_delta: float) -> void:
	
	if not board_node.is_left_click_down:
		transitioning.emit(self, "Dropping Deadline", [current_deadline])
		
		if Global.DEBUG_MODE:
			print("Transitioning to dropping the deadline!")
