class_name OrderGraceState extends State
## This is the initial state of an order. While in this state,
## A timer ticks before the player loses influence from not
## setting the deadline.

## References
@onready var texture_progress_bar: TextureProgressBar = %TextureProgressBar

## The amount of time before a delinquent deadline setup, and the elapsed time
var elapsed_time := 0.0
@export var set_up_seconds := 20.0

	
## Increase the visual progress bar, and transition when the bar is complete	
func update(delta: float) -> void:
	
	elapsed_time += delta
	texture_progress_bar.value = 100 * elapsed_time / set_up_seconds
	
	if texture_progress_bar.value >= 100:
		transitioning.emit(self, "OrderLateState")
