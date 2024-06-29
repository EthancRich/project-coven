class_name StateMachine extends Node

@export var initial_state: State

var states: Dictionary = {}
var current_state: State

func _ready():
	
	# Populate dictionary and connect state machines to their signals
	for child in self.get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.transitioning.connect(on_state_transition)
	
	# Initialize starting state
	if initial_state != null:
		initial_state.enter()
		current_state = initial_state


# Update the current state each frame
func _process(delta: float):
	if current_state != null:
		current_state.update(delta)
		
func _physics_process(delta: float):
	if current_state != null:
		current_state.physics_update(delta)

func on_state_transition(old_state: State, new_state_name: String):
	
	# check to make sure only signals from current state are considered
	if old_state != current_state:	
		return
	
	# Obtain the new state
	var new_state = states.get(new_state_name.to_lower())
	
	# Return if no new state specified
	if new_state == null:
		print("New state to transition to not found")
		return
		
	# Exit current state, and enter next state
	if current_state != null:
		current_state.exit()
	
	# update the reference for the current state
	current_state = new_state
	
	# Enter the next state (comes after for disambiguating immediate transitions)
	new_state.enter()
		
