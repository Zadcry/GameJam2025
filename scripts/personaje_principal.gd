extends CharacterBody2D

@onready var camera := $MainCamera
@onready var cursor_follower := $CursorFollower
var cordura : float = 100.0
var zoomed := false
var zoom_normal := Vector2(1, 1)
var zoom_in := Vector2(2.5, 2.5)
var shake_strenght : float = 0

func _ready():
	randomize()
	camera.zoom = zoom_normal
	camera.position = Vector2.ZERO
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED

func _process(_delta):
	if zoomed:
		follow_cursor()

	var mouse_pos = get_viewport().get_mouse_position()
	var world_mouse_pos = screen_to_world(mouse_pos)
	
	if cordura >= 90 and cordura <= 100:
		shake_strenght = 1.5
		var offset = Vector2(
			randf_range(-shake_strenght, shake_strenght),
			randf_range(-shake_strenght, shake_strenght)
		)
		cursor_follower.global_position = world_mouse_pos + offset	
	else:
		cursor_follower.global_position = world_mouse_pos
	
	if Input.is_action_just_pressed("toggle_zoom"):
		zoomed = !zoomed
		if zoomed:
			camera.zoom = zoom_in
		else:
			camera.zoom = zoom_normal
			camera.position = Vector2.ZERO

func follow_cursor():
	var mouse_pos = get_viewport().get_mouse_position()
	var world_mouse_pos = screen_to_world(mouse_pos)
	var cam_target = global_position.lerp(world_mouse_pos, 0.4)
	camera.global_position = cam_target

func screen_to_world(screen_pos: Vector2) -> Vector2:
	# Usamos el viewport transform + la cámara manualmente
	return camera.get_canvas_transform().affine_inverse() * screen_pos
