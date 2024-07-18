extends Camera2D
## Camera Controller script describes the main camera
## for the game, with the ability to zoom and scroll
## the view for the game board.

## the minimum amount of zoom. Lower number = wider FOV
@export var zoom_min = Vector2(1.0, 1.0)

## the maximum amount of zoom. Higher number = narrower FOV
@export var zoom_max = Vector2(4.0, 4.0)

## How quickly the zoom is adjusted, per input.
@export var zoom_speed = Vector2(0.1, 0.1)

## The number of pixels that the camera moves each panning input
@export var scroll_speed = 40

## Scrolls the camera and pans the camera, on unhandled inputs
## FIXME: This needs a complete overhaul come the finishing touches
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		# Zoom out
		if event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			self.zoom = clamp(self.zoom - zoom_speed, zoom_min, zoom_max)
		# Zoom in
		if event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_UP:
			self.zoom = clamp(self.zoom + zoom_speed, zoom_min, zoom_max)
		
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_W:
			self.offset.y -= scroll_speed
		if event.pressed and event.keycode == KEY_S:
			self.offset.y += scroll_speed
		if event.pressed and event.keycode == KEY_A:
			self.offset.x -= scroll_speed
		if event.pressed and event.keycode == KEY_D:
			self.offset.x += scroll_speed
