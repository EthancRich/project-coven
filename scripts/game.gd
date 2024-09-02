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




## Whenever a job is created, set the game node to listen for job signals
func _on_grid_created_job(new_job: Job) -> void:
	if new_job:
		new_job.job_grew.connect(_on_job_grew)
		new_job.job_shrunk.connect(_on_job_shrunk)
		

## Plays sound for growing job
func _on_job_grew() -> void:
	sounds.play_audio("ExpandJob")
	
	
## Plays sound for shrinking job
func _on_job_shrunk() -> void:
	sounds.play_audio("ShrinkJob")


func _on_dropping_job_dropped(success: bool, _job: Job) -> void:
	if success:
		sounds.play_audio("PlaceJob")
	else:
		sounds.play_audio("InvalidPlaceJob")
