class_name OrderLateState extends State
## This is the state that the order is in if the player
## does not create a deadline in time.
## NOTE: This state gets transitioned on a singal callback
## in the Order Control script.

## References
@onready var timer: Timer = %Timer
@onready var order: OrderControl = $"../.."


## When entering the late state, reduce influence once and then
## Set the timer
func enter(_args: Array) -> void:
	timer.start()
	order._on_timer_timeout()


## Stop the timer once the late state ends
func exit() -> void:
	timer.stop()
	
