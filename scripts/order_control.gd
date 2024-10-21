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
@onready var texture_progress_bar: TextureProgressBar = %TextureProgressBar
@onready var potion_button: PotionButton = $GridContainer/PotionButton

## A preloaded scene for creating deadline objects.
var deadline_scene := preload("res://scenes/deadline.tscn")

## Reference to the deadline object associated with this order
var connected_deadline: Deadline = null

## Determines the type of potion associated with the order
var potion: Item = null

## If true, the associated deadline it met with the timebar
## NOTE: This is set in the Deadline script
var is_deadline_hit := false

## Influence amount to be reduced
var influence_amount := 5

## Signal for game sound effects
signal order_fulfilled
signal reduce_influence_tick(amount: int)


## Sets the order to listen for a state machine's signal
func _ready() -> void:
	order_fulfilled.connect(game_node._on_order_control_order_fulfilled)


func delete() -> void:
	queue_free()
	

## Resets a bool in Button that allows new deadline to be made
## NOTE: This is a called function, not a signaled functions
func on_dropping_deadline_state_deadline_dropped(success: bool) -> void:
	if success:
		$StateMachine.current_state.transitioning.emit($StateMachine.current_state, "OrderSetState")
	else:
		($GridContainer/PotionButton as PotionButton).is_deadline_created = false
 

## Sets the order's potion item type and updates the texture button's textures.
func set_potion(potion_item: Item) -> void:
	print(potion_item.name)
	potion = potion_item
	if not potion_button:
		await get_tree().create_timer(0.01).timeout 
	potion_button.texture_normal = potion.sprite


## Creates a new deadline for the current order
func _on_potion_button_create_new_deadline() -> void:
	# Create a deadline object and add it to the board node
	var deadline := deadline_scene.instantiate() as Deadline
	deadline.connected_order = self
	connected_deadline = deadline
	board_node.add_child(deadline)
	
	# Set the deadline's color
	deadline.set_rect_color(potion.color)
	
	# Set the game node to respond to deadline signal
	deadline.moved_position.connect(game_node._on_deadline_moved_position)
	deadline.late_tick.connect(game_node._on_deadline_late_tick)
	
	# Update the board's knowledge of mouse press
	# It's off because of the GUI eating the press input
	board_node.is_left_click_down = true
	
	# Force the state machine to transition to dragging
	idle_state.transitioning.emit(idle_state, "Dragging Deadline", [deadline])
	

## Reduce influence
func _on_timer_timeout() -> void:
	reduce_influence_tick.emit(influence_amount)
