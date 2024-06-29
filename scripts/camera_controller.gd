extends Camera2D

@export var zoom_min = Vector2(0.21, 0.21)
@export var zoom_max = Vector2(2.0, 2.0)
@export var zoom_speed = Vector2(0.2, 0.2)
@export var scroll_speed = 20

func _unhandled_input(event):
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
