class_name TimeBar extends ColorRect

## The number of squares per second bar moves
@export var squares_per_second: float = 1.0

## The width of a single tile.
## TODO: Replace with a global sort of variable?
var square_width: int = 64

## Calculated value.
var pixels_per_second: float = 0.0


## Initialize pixels_per_second
func _ready() -> void:
	pixels_per_second = squares_per_second * square_width
	

## Called when the game is restarted
func restart() -> void:
	position.x = 0


## Calculate and assign the new position for time bar
func _physics_process(delta: float) -> void:
	position.x += delta * pixels_per_second
