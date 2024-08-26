class_name Deadline extends Node2D
## deadline script defines the functions the visually determine
## a deadline bar's color and transparency.

## The maximum and minimum transparency, from 0 to 1.
@export var max_transparency := 1.0
@export var min_transparency := 0.0

## The speed of the pulsing, with 1 as the normal speed.
@export var pulse_speed := 1.0

## References to the children rectangles, for reduction in calls.
@onready var inner_rect := $InnerRect as Control
@onready var outer_rect := $OuterRect as Control

## Whether the deadline is set or not.
## Unset deadlines follow the player's mouse,
## Set deadlines monitor for the produced potions.
var is_set := false

## The amount of elapsed time for animation tracking.
var elapsed_time := 0.0

## The order that this deadline is associated with.
var connected_order: OrderControl = null


## Initialize Transparency
func _ready() -> void:
	position.y = 0
	set_transparency(0.0)


## Updates each frame.
func _process(delta: float) -> void:
	
	if is_set:
		# TODO: Monitor task completion vs timer
		update_order_label()
	else:
		# Update the bar's mouse position
		update_deadline_x_position()
	
	# Update the blinking animation
	elapsed_time += delta
	set_transparency(elapsed_time)
	if elapsed_time > PI:
		elapsed_time = elapsed_time - PI


## Snaps the bar's x position to a neraby grid marker
func update_deadline_x_position() -> void:
	
	var tolerance := 10 # 32 is max, 0 is min
	var mouse_pos_x := get_global_mouse_position().x
	var modulo := fmod(mouse_pos_x, 64)
	
	# Update the position if close enough to a gridline
	if (modulo - 32) < -tolerance:
		position.x = mouse_pos_x - modulo
	elif (modulo - 32) > tolerance:
		position.x = mouse_pos_x + (64 - modulo)
	
	# If it's still far away, force adjustment to be made
	# This will snap to the nearest gridline even if not in tolerance
	if abs(mouse_pos_x - position.x) >= 64:
		if modulo < 32:
			position.x = mouse_pos_x - modulo
		else:
			position.x = mouse_pos_x + (64 - modulo)


## Update the appropriate order's label as time bar passes.
func update_order_label():
	
	# Get the label objects of the order
	var num_label := connected_order.get_node("GridContainer/NumLabel") as Label
	var text_label := connected_order.get_node("GridContainer/TextLabel") as Label
	
	# Get the difference between the time bar and deadline to calculate boxes apart
	var pixel_diff := global_position.x - ($"../TimeBar" as ColorRect).global_position.x

	# Adjust the labels based on the distance
	if pixel_diff > 0:
		num_label.text = str(int(pixel_diff) / 64)
	else:
		num_label.text = "Past"
		text_label.text = " Due"
	

## Sets the transparency of the rectangles, with a fade in the outer
func set_transparency(t: float) -> void:
	var new_val := get_new_transparency(t)
	outer_rect.modulate.a = new_val * 0.8
	inner_rect.modulate.a = new_val

	
## Uses a sine function to get a sinusoidal fluctuating value,
## normalized between the min and max transparency values.
func get_new_transparency(t: float) -> float:
	var zero_to_one := 0.5 * (1 + cos(t * pulse_speed))
	return min_transparency + (max_transparency - min_transparency) * zero_to_one


## Passes the (rgb) inputs to both rectangles.
func set_rect_color(r: int, g: int, b: int) -> void:
	outer_rect.modulate.r = r
	outer_rect.modulate.g = g
	outer_rect.modulate.b = b
	inner_rect.modulate.r = r
	inner_rect.modulate.g = g
	inner_rect.modulate.b = b
