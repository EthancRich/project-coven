class_name Game extends Node
## Game script carries out the overarching gameplay
## Coordination and tracking tasks that are
## board and static agnostic.

## Preloads and References
@onready var sounds: AudioManager = %Sounds as AudioManager
@onready var influence_val_label: Label = $"../Interface/LeftInterface/PanelContainer/MarginContainer/VBoxContainer/TopPanel/HBoxContainer2/InfluenceValLabel" as Label
@onready var influence_diff_label: Label = $"../Interface/LeftInterface/PanelContainer/MarginContainer/VBoxContainer/TopPanel/HBoxContainer2/InfluenceDiffLabel" as Label
var potion_order_scene = preload("res://scenes/order_control.tscn")

## The health and money resource
var influence: int

## The difference considered to be combined if option is successful
var influence_diff: int


## TODO: Automate the process of creating orders
func _ready() -> void:
	create_order(0)
	create_order(0)
	set_influence_instant(100)
	#set_potential_influence_diff(-4)


## Instantiate a new order, and pass it to the UI to add
func create_order(potion_enum: int) -> void:
	var new_order := potion_order_scene.instantiate() as OrderControl
	new_order.set_potion_type(potion_enum)
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
