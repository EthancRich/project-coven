class_name OrderControl extends Control
## order control script provides additional information
## for the order and propagates the deadline information
## by capturing the signal from the potion button and
## converting it into a deadline object.

## Reference to the other nodes for creating new deadlines
@onready var game_node := get_node("/root/Main/Game") as Game
@onready var board_node := get_node("/root/Main/Game/Board") as Board
@onready var idle_state := get_node("/root/Main/Game/Board/StateMachine/Idle") as State
@onready var dropping_state := get_node("/root/Main/Game/Board/StateMachine/Dropping Deadline") as DroppingDeadlineState

## A preloaded scene for creating deadline objects.
var deadline_scene := preload("res://scenes/deadline.tscn")

## Reference to the deadline object associated with this order
var connected_deadline: Deadline = null

## Determines the type of potion associated with the order
var potion: Item = null

## If true, the associated deadline it met with the timebar
## NOTE: This is set in the Deadline script
var is_deadline_hit := false

## Signal for game sound effects
signal order_fulfilled


## Sets the order to listen for a state machine's signal
func _ready() -> void:
	dropping_state.deadline_dropped.connect(_on_dropping_deadline_state_deadline_dropped)
	order_fulfilled.connect(game_node._on_order_control_order_fulfilled)


## Tries to fulfill the order if the deadline is set
func _process(_delta: float) -> void:
	if is_deadline_hit:
		if attempt_fulfill_order():
			connected_deadline.queue_free()
			queue_free()


## Try to complete the order by looking for pickup jobs with the desired potion
func attempt_fulfill_order() -> bool:
	
	# Get the pick up jobs on the board
	var pickup_jobs := get_tree().get_nodes_in_group("pickup")
	
	# Check if they have the right items
	for job: Job in pickup_jobs:
		if not job:
			continue
			
		for item: Item in job.input_items_array:
			if item.id == potion.id:
				fulfill_order(job, item)
				return true
	
	# If no item is found, return false
	return false


## Consume the potion produced, and emit signal for sound effects
func fulfill_order(job: Job, removal_item: Item) -> void:
	job.input_items_array.erase(removal_item)
	order_fulfilled.emit()


## Resets a bool in Button that allows new deadline to be made
## FIXME: Currently, all orders receive this signal, when we only want the related one to signal
func _on_dropping_deadline_state_deadline_dropped(success: bool) -> void:
	if not success:
		($GridContainer/PotionButton as PotionButton).is_deadline_created = false
 

## Sets the order's potion item type and updates the texture button's textures.
func set_potion(potion_item: Item) -> void:
	potion = potion_item


## Creates a new deadline for the current order
func _on_potion_button_create_new_deadline() -> void:
	# Create a deadline object and add it to the board node
	var deadline := deadline_scene.instantiate() as Deadline
	deadline.connected_order = self
	connected_deadline = deadline
	board_node.add_child(deadline)
	
	# Set the game node to respond to deadline signal
	deadline.moved_position.connect(game_node._on_deadline_moved_position)
	
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
	
