extends CharacterBody2D

## the minimum amount of zoom. Lower number = wider FOV
@export var zoom_min = Vector2(1.0, 1.0)

## the maximum amount of zoom. Higher number = narrower FOV
@export var zoom_max = Vector2(4.0, 4.0)

## How quickly the zoom is adjusted, per input.
@export var zoom_speed = Vector2(0.1, 0.1)

## The number of pixels that the camera moves each panning input
@export var base_speed := 200.0
var speed := base_speed
@onready var camera_2d: Camera2D = $Camera2D
@onready var left_border: CollisionShape2D = $"../WorldBorders/LeftBorder"

func _physics_process(delta: float) -> void:

	var input_direction := Input.get_vector("left", "right", "up", "down")
	self.velocity = input_direction * speed
	move_and_slide()
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		
		
		# Zoom out
		if event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera_2d.zoom = clamp(camera_2d.zoom - zoom_speed, zoom_min, zoom_max)
			$CollisionShape2D.shape.size.x = 1920 / camera_2d.zoom.x
			$CollisionShape2D.shape.size.y = 1080 / camera_2d.zoom.y
			camera_2d.limit_left = -320 / camera_2d.zoom.x
			left_border.shape.distance = -320 / camera_2d.zoom.x
			speed = 4 * base_speed / camera_2d.zoom.x
		# Zoom in
		if event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera_2d.zoom = clamp(camera_2d.zoom + zoom_speed, zoom_min, zoom_max)
			$CollisionShape2D.shape.size.x = 1920 / camera_2d.zoom.x
			$CollisionShape2D.shape.size.y = 1080 / camera_2d.zoom.y
			camera_2d.limit_left = -320 / camera_2d.zoom.x
			left_border.shape.distance = -320 / camera_2d.zoom.x
			speed = 4 * base_speed / camera_2d.zoom.x
