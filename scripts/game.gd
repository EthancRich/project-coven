class_name Game extends Node
## Game script carries out the overarching gameplay
## Coordination and tracking tasks that are
## board and static agnostic.

## Flag to help test things
var debug_flag := true

## Preloads and References
@onready var sounds: AudioManager = %Sounds as AudioManager
@onready var time_bar: TimeBar = %TimeBar as TimeBar
var left_interface: LeftInterface
var potion_order_scene = preload("res://scenes/order_control.tscn")
@export var potion_1: Item
@export var potion_2: Item
@export var witch_scene: PackedScene

## The influence cost of a single witch; can be modified over the runtime
var witch_cost := 50
var num_witches := 2

## The health and money resource
var influence: int = 100

## The difference considered to be combined if option is successful
var influence_diff: int


## TODO: Automate the process of creating orders
func _ready() -> void:
	create_order(potion_1)
	create_order(potion_1)
	
	# Set up the left interface signal connections
	left_interface = $"../Interface/LeftInterface" as LeftInterface
	left_interface.recruit_hovered.connect(_on_recruit_button_recruit_hovered)
	left_interface.recruit_pressed.connect(_on_recruit_button_recruit_pressed)
	left_interface.recruit_unhovered.connect(_on_recruit_button_recruit_unhovered)
	
	set_influence_instant(100)


## Instantiate a new order, and pass it to the UI to add
func create_order(new_potion: Item) -> void:
	var new_order := potion_order_scene.instantiate() as OrderControl
	new_order.set_potion(new_potion)
	new_order.reduce_influence_tick.connect(_on_order_control_reduce_influence_tick)
	($"../Interface" as Interface).add_potion_order(new_order)


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
		witch_cost += 25
		set_potential_influence_diff(-1 * witch_cost)
		num_witches += 1
		
		# Update the left interface images
		left_interface.reveal_witch_image(num_witches)
		
		# Create witch and assign it to the board node
		var witch: Witch = witch_scene.instantiate()
		witch.global_position = Vector2(32, 32)
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
