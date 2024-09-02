class_name Game extends Node
## Game script carries out the overarching gameplay
## Coordination and tracking tasks that are
## board and static agnostic.

## Preloads and References
@onready var sounds: AudioManager = %Sounds as AudioManager
var potion_order_scene = preload("res://scenes/order_control.tscn")


## Create orders to start
## TODO: Automate this process
func _ready() -> void:
	create_order(0)
	create_order(0)


## Instantiate a new order, and pass it to the UI to add
func create_order(potion_enum: int) -> void:
	var new_order := potion_order_scene.instantiate() as OrderControl
	new_order.set_potion_type(potion_enum)
	($"../Interface" as Interface).add_potion_order(new_order)




## AUDIO CALLBACKS

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
