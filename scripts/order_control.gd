class_name OrderControl extends Control
## order control script provides additional information
## for the order and propagates the deadline information
## by capturing the signal from the potion button and
## converting it into a deadline object.

## Reference to the other nodes for creating new deadlines
@onready var board_node := get_node("/root/Main/Game/Board") as Board
@onready var idle_state := get_node("/root/Main/Game/Board/StateMachine/Idle") as State
@onready var dropping_state := get_node("/root/Main/Game/Board/StateMachine/Dropping Deadline") as DroppingDeadlineState

## A preloaded scene for creating deadline objects.
var deadline_scene := preload("res://scenes/deadline.tscn")

## Determines the type of potion associated with the order
var potion_enum := -1
	

## Sets the order to listen for a state machine's signal
func _ready() -> void:
	dropping_state.failed_deadline_drop.connect(failed_deadline_drop)


## Resets a bool in Button that allows new deadline to be made
func failed_deadline_drop() -> void:
	($GridContainer/PotionButton as PotionButton).is_deadline_created = false
 

## Sets the order's potion enum and updates the texture button's textures.
func set_potion_type(new_potion_enum: int) -> void:
	potion_enum = new_potion_enum
	# TODO: Update and assign the texture button accordingly


func _on_potion_button_create_new_deadline() -> void:
	# Create a deadline object and add it to the board node
	var deadline := deadline_scene.instantiate() as Deadline
	deadline.connected_order = self
	board_node.add_child(deadline)
	
	# Update the board's knowledge of mouse press
	# It's off because of the GUI eating the press input
	board_node.is_left_click_down = true
	
	# Flip the button visibly briefly
	# This is so stupid but necessary for the button to not
	# Eat the button release signal on the backend
	$GridContainer/PotionButton.visible = false
	$GridContainer/PotionButton.visible = true
	
	# Force the state machine to transition to dragging
	idle_state.transitioning.emit(idle_state, "Dragging Deadline", [deadline])
	
