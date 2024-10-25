class_name Game extends Node
## Game script carries out the overarching gameplay
## Coordination and tracking tasks that are
## board and static agnostic.

## Flag to help test things
var debug_flag := false

## Signals whether the game is won or lost
## NOTE: 1 == WON, 0 == LOST
signal game_ended(game_state: int)

## Preloads and References
@onready var sounds: AudioManager = %Sounds as AudioManager
@onready var time_bar: TimeBar = %TimeBar as TimeBar
var left_interface: LeftInterface
var order_container: VBoxContainer
var potion_order_scene = preload("res://scenes/order_control.tscn")
@export var witch_scene: PackedScene

@export var potion_1: Item
@export var potion_2: Item
@export var potion_3: Item
@export var potion_4: Item
@export var potion_5: Item
@export var potion_6: Item

## The influence cost of a single witch; can be modified over the runtime
var witch_cost := 50
var num_witches := 2

## The health and money resource
var influence: int = 0
@export var initial_influence: int = 100
@export var winning_influence: int = 500

## The difference considered to be combined if option is successful
var influence_diff: int

## The number of orders that have passed
var order_count: int = 1
var current_potion_in_order: int = 0

## Sets up the connections to the UI, sets the starting influence, and creates the first order
func _ready() -> void:
	
	# Set up the left interface signal connections
	left_interface = $"../Interface/LeftInterface" as LeftInterface
	left_interface.recruit_hovered.connect(_on_recruit_button_recruit_hovered)
	left_interface.recruit_pressed.connect(_on_recruit_button_recruit_pressed)
	left_interface.recruit_unhovered.connect(_on_recruit_button_recruit_unhovered)
	
	# Set a reference to the order_container (I know this is bad practice, sorry)
	order_container = left_interface.get_node("PanelContainer/MarginContainer/VBoxContainer/BottomPanel/ScrollContainer/OrderContainer")
	
	set_influence_instant(initial_influence)
	
	# Start the first batch of orders
	$InitialOrderBuffer.start()
	

## Checks the game state, whether won or lost
func _process(delta: float) -> void:
	if influence >= winning_influence:
		game_ended.emit(1)
	elif influence <= 0:
		game_ended.emit(0)


## Creates the first set of the orders for the game
func _on_initial_order_buffer_timeout() -> void:
	create_next_order_batch()


## Called when the game is restarted.
func restart() -> void:
	set_influence_instant(100)
	num_witches = 2
	witch_cost = 50
	order_count = 1
	current_potion_in_order = 0
	$InitialOrderBuffer.start()


## Decides which order to make, and then creates it
func create_next_order_batch() -> void:
	
	# Update the order count
	order_count += 1
	current_potion_in_order = 0 # If not already at 0
	
	# Points contains a point value, half the order number rounded up
	var points: int = ceil(order_count / 2.0)
	print(points)
	
	while points > 0:
		# Choose an order difficulty, and add to queue if there are enough points
		var order_difficulty: int = floor(3 * randf())
		print(order_difficulty)
		
		match order_difficulty:
			0:
				points -= 1
				create_small_order()
				await get_tree().create_timer(15.0).timeout
			1:
				if points < 2:
					continue
				points -= 2
				create_medium_order()
				await get_tree().create_timer(30.0).timeout
			2:
				if points < 3:
					continue
				points -= 3
				create_hard_order()
				await get_tree().create_timer(45.0).timeout
	

func create_small_order():
	var potion_type: int = floor(3.0 * randf())
	match potion_type:
		0:
			create_order(potion_1)
		1:
			create_order(potion_2)
		2:
			create_order(potion_3)
	
	
func create_medium_order():
	var potion_type: int = floor(2.0 * randf())
	match potion_type:
		0:
			create_order(potion_4)
		1:
			create_order(potion_5)
	
	
func create_hard_order():
	create_order(potion_6)


## Instantiate a new order, and pass it to the UI to add
func create_order(new_potion: Item) -> void:
	var new_order := potion_order_scene.instantiate() as OrderControl
	new_order.reduce_influence_tick.connect(_on_order_control_reduce_influence_tick)
	($"../Interface" as Interface).add_potion_order(new_order)
	new_order.set_potion(new_potion)
	current_potion_in_order += 1


## Update the value of influence_diff
func set_potential_influence_diff(new_diff: int) -> void:
	influence_diff = new_diff
	update_influence_labels()


## finalize the difference into the new influence
func confirm_influence_change() -> void:
	influence += influence_diff
	left_interface.play_influence_label_animation(influence_diff)
	influence_diff = 0
	update_influence_labels()
	

## Bypass influence diff system and hard set influence
func set_influence_instant(new_influence: int) -> void:
	var instant_diff = new_influence - influence
	influence = new_influence
	left_interface.play_influence_label_animation(instant_diff)
	influence_diff = 0
	update_influence_labels()
	

## Updates the influence label depending on the value
func update_influence_labels() -> void:
	
	var influence_val_str: String = ""
	var influence_diff_str: String = ""
	
	if influence_diff == 0:
		influence_val_str = str(influence)
	else:
		influence_val_str = "(" + str(influence + influence_diff) + ")"
		influence_diff_str = str(influence_diff)
		
	left_interface.set_influence_labels(influence_val_str, influence_diff_str)
	

## Updates the influence when the deadline is dropped
func _on_dropping_deadline_deadline_dropped(success: bool) -> void:
	if success:
		confirm_influence_change()
		sounds.play_audio("PlaceJob")
	else:
		set_potential_influence_diff(0)
		sounds.play_audio("InvalidPlaceJob")


## Gets the difference between the deadline and time bar and updates the influence diff
func _on_deadline_moved_position(deadline_position: Vector2) -> void:
	sounds.play_audio("DropPipePiece")
	
	var pixel_diff := int(deadline_position.x - time_bar.position.x)
	set_potential_influence_diff(calculate_influence_difference(pixel_diff))


## When the deadline is late, reduce the influence by the given amount
func _on_deadline_late_tick(amount: int) -> void:
	sounds.play_audio("OrderFailed")
	set_influence_instant(influence - amount)


## When the order's deadline isn't set in time, then reduce influence
func _on_order_control_reduce_influence_tick(amount: int) -> void:
	sounds.play_audio("OrderFailed")
	set_influence_instant(influence - amount)
	

## Converts a pixel diff into an influence diff for deadlines
func calculate_influence_difference(pixels: int) -> int:
	
	# Time bar is ahead of the deadline
	if pixels < 0:
		return 0
	# Deadline is ahead of time bar
	return -1 * (pixels / 64) - 1


func _on_order_control_order_fulfilled() -> void:
	sounds.play_audio("OrderFulfilled")
	set_influence_instant(influence + 30)
	# TODO: Change to be an order component and not a fixed value
	
	current_potion_in_order -= 1
	if current_potion_in_order == 0:
		await get_tree().create_timer(5.0).timeout
		create_next_order_batch()


## RECRUITING WITCH CALLBACKS ##
func _on_recruit_button_recruit_hovered() -> void:
	set_potential_influence_diff(-1 * witch_cost)
	
	
func _on_recruit_button_recruit_unhovered() -> void:
	set_potential_influence_diff(0)
	
	
func _on_recruit_button_recruit_pressed() -> void:
	
	if influence + influence_diff > 0 or debug_flag:
		
		# Play sound effect
		sounds.play_audio("OrderFulfilled")
		
		# Update influence and witch cost
		confirm_influence_change()
		#witch_cost += 25
		set_potential_influence_diff(-1 * witch_cost)
		num_witches += 1
		
		# Update the left interface images
		left_interface.reveal_witch_image(num_witches)
		
		# Create witch and assign it to the board node
		var witch: Witch = witch_scene.instantiate()
		witch.global_position = $CameraController.global_position
		$Board.add_child(witch)
		
		# Disable recruit button if there are max witches
		if num_witches >= 8:
			left_interface.disable_recruit_button()
		
	else:
		sounds.play_audio("InvalidPlaceJob")


## AUDIO CALLBACKS ##
func _on_job_grew() -> void:
	sounds.play_audio("ExpandJob")
	
	
func _on_job_shrunk() -> void:
	sounds.play_audio("ShrinkJob")


func _on_job_complete() -> void:
	sounds.play_audio("CompleteJob")


func _on_job_deleted() -> void:
	sounds.play_audio("DeleteJob")


func _on_dropping_job_dropped(success: bool, _job: Job) -> void:
	if success:
		sounds.play_audio("PlaceJob")
	else:
		sounds.play_audio("InvalidPlaceJob")
		

func _on_witch_landlocked() -> void:
	sounds.play_audio("InvalidPlaceJob")


func _on_dropping_pipe_pipe_piece_dropped() -> void:
	sounds.play_audio("DropPipePiece")


func _on_erasing_pipe_pipe_piece_erased() -> void:
	sounds.play_audio("DropPipePiece")


func _on_ending_pipe_pipe_dropped() -> void:
	sounds.play_audio("PlaceJob")
	
	
func _on_pipe_deleted() -> void:
	sounds.play_audio("DeleteJob")



