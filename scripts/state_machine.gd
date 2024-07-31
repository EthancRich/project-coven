class_name StateMachine extends Node
## State Machine is a general state machine script to handle
## A set of states and their transition to each other.

## The first state that the machine will start in.
@export var initial_state: State

## The current state that the machine is currently handling.
var current_state: State

## A dictionary of key pairs (StateName, StateReference)
var states: Dictionary = {}


## Set up dictionary, states, and initial state
func _ready() -> void:
	
	# Populate Dictionary and connect states to the transition signal
	for child in self.get_children():
		if child is State:
			var state := child as State
			states[state.name.to_lower()] = child
			state.transitioning.connect(on_state_transition)
	
	# Initialize starting state
	if initial_state != null:
		initial_state.enter([])
		current_state = initial_state


## Calls the update function of the current state each frame
func _process(delta: float) -> void:
	if current_state != null:
		current_state.update(delta)
	
	
## Calls the physics_update function of the current state each frame
func _physics_process(delta: float) -> void:
	if current_state != null:
		current_state.physics_update(delta)


## transitions from old to new state, calling the enter and exit on each accordingly
func on_state_transition(old_state: State, new_state_name: String, args: Array = []) -> void:
	
	# check to make sure only signals from current state are considered
	if old_state != current_state:	
		return
	
	# Obtain the new state
	var new_state := states.get(new_state_name.to_lower()) as State
	
	# Return if no new state specified
	if new_state == null:
		if Global.DEBUG_MODE:
			push_error(self.name, " [on_state_transition]", "No state specified, stopping state machine.")
		return
		
	# Exit current state, and enter next state
	if current_state != null:
		current_state.exit()
	
	# update the reference for the current state
	current_state = new_state
	
	# Enter the next state (comes after for disambiguating immediate transitions)
	new_state.enter(args)
		
