class_name Game extends Node
## Game script carries out the overarching gameplay
## Coordination and tracking tasks that are
## board and static agnostic.

## Preloads and References
@onready var sounds: AudioManager = %Sounds as AudioManager
@onready var influence_val_label: Label = $"../Interface/LeftInterface/PanelContainer/MarginContainer/VBoxContainer/TopPanel/HBoxContainer2/InfluenceValLabel" as Label
@onready var influence_diff_label: Label = $"../Interface/LeftInterface/PanelContainer/MarginContainer/VBoxContainer/TopPanel/HBoxContainer2/InfluenceDiffLabel" as Label
@onready var time_bar: TimeBar = %TimeBar as TimeBar
var potion_order_scene = preload("res://scenes/order_control.tscn")
@export var potion_1: Item
@export var potion_2: Item

## The health and money resource
var influence: int

## The difference considered to be combined if option is successful
var influence_diff: int


## TODO: Automate the process of creating orders
func _ready() -> void:
	create_order(potion_1)
	create_order(potion_1)
	set_influence_instant(100)


## Instantiate a new order, and pass it to the UI to add
func create_order(new_potion: Item) -> void:
	var new_order := potion_order_scene.instantiate() as OrderControl
	new_order.set_potion(new_potion)
	($"../Interface" as Interface).add_potion_order(new_order)


## Update the value of influence_diff
func set_potential_influence_diff(new_diff: int) -> void:
	influence_diff = new_diff
	update_influence_labels()


## finalize the difference into the new influence
func confirm_influence_change() -> void:
	influence += influence_diff
	influence_diff = 0
	update_influence_labels()


## Bypass influence diff system and hard set influence
func set_influence_instant(new_influence: int) -> void:
	influence = new_influence
	influence_diff = 0
	update_influence_labels()
	

## Updates the influence label depending on the value
func update_influence_labels() -> void:
	
	if influence_diff == 0:
		influence_val_label.text = str(influence)
		influence_diff_label.text = ""
		return
		
	influence_val_label.text = "(" + str(influence + influence_diff) + ")"
	influence_diff_label.text = str(influence_diff)
	

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


## Converts a pixel diff into an influence diff for deadlines
func calculate_influence_difference(pixels: int) -> int:
	
	# Time bar is ahead of the deadline
	if pixels < 0:
		return 0
	# Deadline is ahead of time bar
	return -1 * (pixels / 64) - 1


## AUDIO CALLBACKS ##
func _on_job_grew() -> void:
	sounds.play_audio("ExpandJob")
	
	
func _on_job_shrunk() -> void:
	sounds.play_audio("ShrinkJob")


func _on_job_complete() -> void:
	sounds.play_audio("CompleteJob")


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


func _on_order_control_order_fulfilled() -> void:
	sounds.play_audio("OrderFulfilled")
