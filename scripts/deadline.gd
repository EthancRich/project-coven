class_name Deadline extends Node2D
## deadline script defines the functions the visually determine
## a deadline bar's color and transparency.

## The maximum and minimum transparency, from 0 to 1.
@export var max_transparency := 1.0
@export var min_transparency := 0.0

## The speed of the pulsing, with 1 as the normal speed.
@export var pulse_speed := 1.0

## The amount of the influence lost with this deadline
var late_deadline_tick_amount := 5

## References to the children rectangles, for reduction in calls.
@onready var inner_rect := $InnerRect as ColorRect
@onready var outer_rect := $OuterRect as ColorRect

## Whether the deadline is set or not.
## Unset deadlines follow the player's mouse,
## Set deadlines monitor for the produced potions.
var is_set := false
var is_hit := false

## The amount of elapsed time for animation tracking.
var elapsed_time := 0.0

## The order that this deadline is associated with.
var connected_order: OrderControl = null

## The previous quotient for calculating the late penalties.
var prev_quotient := -1

## Signals
signal moved_position(deadline_global_position: Vector2)
signal late_tick(amount: int)


## Initialize Transparency
func _ready() -> void:
	position.y = 0
	set_transparency(0.0)


## Called when the game restarts.
func delete() -> void:
	queue_free()

## Updates each frame.
func _process(delta: float) -> void:
	
	if is_hit:
		attempt_reduce_influence()
	
	if is_set:
		update_deadline_state()
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
	var prev_x := position.x
	
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
			
	# If the deadline changed positions, emit the appropriate signal
	if prev_x != position.x:
		moved_position.emit(global_position)


## Updates the labels and the order itself depending on the deadline and time bar
func update_deadline_state() -> void:
	var pixel_diff := global_position.x - ($"../TimeBar" as ColorRect).global_position.x
	update_order_label(pixel_diff)
	
	if pixel_diff <= 0:
		connected_order.is_deadline_hit = true
		is_hit = true


## Update the appropriate order's label as time bar passes.
func update_order_label(pixel_diff) -> void:
	
	# Get the label objects of the order
	var num_label := connected_order.get_node("GridContainer/NumLabel") as Label
	var text_label := connected_order.get_node("GridContainer/TextLabel") as Label

	# Adjust the labels based on the distance
	if pixel_diff > 0:
		num_label.text = str(int(pixel_diff) / 64)
		text_label.text = "Left"
	else:
		num_label.text = ""
		text_label.text = "Due"
		

## Based on the difference between the time bar and deadline positions, reduce influence
func attempt_reduce_influence() -> void:
	
	# Get pixel difference
	var pixel_diff := ($"../TimeBar" as ColorRect).global_position.x - global_position.x
	
	# NOTE: This value can be changed for frequency of late hits, pixel modulus
	var mod := 32
	
	var current_quotient = int(pixel_diff) / mod
	
	if current_quotient > prev_quotient:
		prev_quotient = current_quotient
		late_tick.emit(late_deadline_tick_amount)
	

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
func set_rect_color(new_color: Color) -> void:
	outer_rect.color = new_color
	inner_rect.color = new_color
