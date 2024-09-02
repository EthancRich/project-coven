extends Control
## BottomInterface is a script that manages the bottom interface
## in the GUI. If a button in the GUI is dragged out of, this
## script will communicate with the game node to create and
## begin to place the new job.


## Node references that are necessary for signal connections.
@onready var game_node := get_node("/root/Main/Game") as Game
@onready var board_node := get_node("/root/Main/Game/Board") as Board
@onready var grid_node := get_node("/root/Main/Game/Board/Grid") as Grid
@onready var idle_state := get_node("/root/Main/Game/Board/StateMachine/Idle") as State
@onready var dropping_state := get_node("/root/Main/Game/Board/StateMachine/Dropping Job") as DroppingJobState

## True if the self is attempting to drop job, false otherwise.
var gui_job_dropping := false

## On start up, expand the menu and set the connection
func _ready() -> void:
	dropping_state.dropped.connect(on_dropped_job)
	expand_shrink_menu(false)


## If toggled_on is true, then the context menu for the stations
## gets expanded; otherwise, the menu is set to invisible.
func expand_shrink_menu(toggled_on: bool) -> void:
	if toggled_on:
		($PanelContainer as PanelContainer).visible = true
		($CollapseButton as Button).position.y = -31
		($CollapseButton as Button).button_pressed = true
	else:
		($PanelContainer as PanelContainer).visible = false
		($CollapseButton as Button).position.y = 168
		($CollapseButton as Button).button_pressed = false


## Creates a new job from the scene, instantiates it, and
## Updates the state machine to begin attempting to drop it.
func _on_texture_button_create_new_job(job_scene: PackedScene) -> void:
	
	# Track state for this job
	gui_job_dropping = true
	
	# Close the context menu
	# TODO: Make ESC key cancel this event or something like it
	expand_shrink_menu(false)
	
	# Create an instance of the job
	var job := job_scene.instantiate() as Job
	job.position = Vector2(-1000, 1000)
	
	# Set the job as the focused object of board
	board_node.remove_focused_object()
	job.add_to_group("focused")
	board_node.focused_job_segment = 0
	
	# Add the job to the scene tree under grid
	grid_node.add_child(job)
	
	# Set the game node to listen to the new job's signals
	job.job_grew.connect(game_node._on_job_grew)
	job.job_shrunk.connect(game_node._on_job_shrunk)
	
	# Update the board's knowledge of mouse press
	# It's off because of the GUI eating the press input
	board_node.is_left_click_down = true
	
	# Force the state machine to transition to dragging
	idle_state.transitioning.emit(idle_state, "Dragging Job")
	
	
## Whenever a job is attempted to drop.
## Delete the job if it was created in the GUI and failed to drop.
func on_dropped_job(successful_drop: bool, job: Job):
	
	# If this result isn't from this GUI moving a job, ignore
	if !gui_job_dropping:
		return
	gui_job_dropping = false
		
	# Delete the job if it wasn't placed in the grid
	if !successful_drop: 
		job.queue_free()
	
	# Pop the menu back up regardless of outcome
	expand_shrink_menu(true)
