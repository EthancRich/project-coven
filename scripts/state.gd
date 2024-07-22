class_name State extends Node
## State is a base class to be inherited from.
## It's equipped with functions called on entry, exit,
## as well as frame-by-frame functions. The state
## can be transitioning by emitting the transitioning signal.

## Triggers the state to transition
signal transitioning


func enter(_args: Array) -> void:
	pass


func exit() -> void:
	pass
	
	
func update(_delta: float) -> void:
	pass
	
	
func physics_update(_delta: float) -> void:
	pass
