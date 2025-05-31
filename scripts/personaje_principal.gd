extends CharacterBody2D

@onready var camera := $MainCamera
@onready var cursor_follower := $CursorFollower
@onready var flash_rect := $PantallaFlash

const CURSOR_NORMAL = preload("res://images/puntero.png")
const CURSOR_ZOOMED = preload("res://images/ScopeReescalada.png")
const FLASH_DURATION := 0.75

var cordura : float
var zoomed := false
var zoom_normal := Vector2(1, 1)
var zoom_in := Vector2(2.5, 2.5)
var shake_strenght : float
var time := 0.0
var amplitude : float = 0.0
var frequency : float = 0.0
var flash_timer = 0.0
var flashing := false

func _ready():
	randomize()
	camera.zoom = zoom_normal
	camera.position = Vector2.ZERO
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN
	cordura = GLOBAL.cordura
	flash_rect.visible = false

func _process(delta):
	time+=delta
	if zoomed:
		follow_cursor()

	var mouse_pos = get_viewport().get_mouse_position()
	var world_mouse_pos = screen_to_world(mouse_pos)
	
	if flashing:
		flash_timer += delta
		var t = flash_timer/FLASH_DURATION
		flash_rect.modulate.a = lerp(1.0, 0.0, t)
		if t >= 1.0:
			flashing = false
			flash_rect.visible = false
	
	if GLOBAL.cordura > 95.0 and GLOBAL.cordura <= 100.0:
		amplitude = 2.5
		frequency = 1.5
		# Poner audio de latidos + respiración
		var offset_x = sin(time * frequency) * amplitude
		var offset_y = cos(time * frequency * 1.3) * amplitude * 0.7
		var offset = Vector2(offset_x, offset_y)
		cursor_follower.global_position = world_mouse_pos + offset
	elif GLOBAL.cordura > 85.0 and GLOBAL.cordura <= 95:
		# Poner audio de percusión
		amplitude = 3.5
		frequency = 2.5
		var offset_x = sin(time * frequency) * amplitude
		var offset_y = cos(time * frequency * 1.3) * amplitude * 0.7
		var offset = Vector2(offset_x, offset_y)
		cursor_follower.global_position = world_mouse_pos + offset
	elif GLOBAL.cordura > 70 and GLOBAL.cordura <= 85:
		# Audio música
		var shake_strength = 0.4  # <-------
		var offset = Vector2(
			randf_range(-shake_strength, shake_strength),
			randf_range(-shake_strength, shake_strength)
		)
		cursor_follower.global_position = world_mouse_pos + offset
	elif GLOBAL.cordura > 60 and GLOBAL.cordura <= 70:
		# No respiración + glitches
		var shake_strength = 0.8  
		var offset = Vector2(
			randf_range(-shake_strength, shake_strength),
			randf_range(-shake_strength, shake_strength)
		)
		cursor_follower.global_position = world_mouse_pos + offset
	elif GLOBAL.cordura > 45 and GLOBAL.cordura <= 60:
		# No respiración + glitch bajo
		cursor_follower.global_position = world_mouse_pos
	elif GLOBAL.cordura > 35 and GLOBAL.cordura <= 45:
		# Música tensa + susurros
		cursor_follower.global_position = world_mouse_pos
	elif GLOBAL.cordura > 20 and GLOBAL.cordura <= 35:
		# Glitch medio
		cursor_follower.global_position = world_mouse_pos
	elif GLOBAL.cordura > 10 and GLOBAL.cordura <= 20:
		# Música (?
		cursor_follower.global_position = world_mouse_pos
	elif GLOBAL.cordura >= 1 and GLOBAL.cordura <= 10:
		# Glitch (???
		cursor_follower.global_position = world_mouse_pos
	elif GLOBAL.cordura < 1:
		# Visuales grises, cambio de ????? - saturación, viñeta
		cursor_follower.global_position = world_mouse_pos
	
	if Input.is_action_just_pressed("toggle_zoom"):
		zoomed = !zoomed
		if zoomed:
			camera.zoom = zoom_in
			cursor_follower.texture = CURSOR_ZOOMED
			cursor_follower.scale = Vector2(0.81,0.81)
		else:
			camera.zoom = zoom_normal
			camera.position = Vector2.ZERO
			cursor_follower.texture = CURSOR_NORMAL
			cursor_follower.scale = Vector2(0.5,0.5)

func follow_cursor():
	var mouse_pos = get_viewport().get_mouse_position()
	var world_mouse_pos = screen_to_world(mouse_pos)
	var cam_offset = (world_mouse_pos - global_position).clamp(-Vector2(300, 200), Vector2(300, 200))
	var target_position = global_position + cam_offset

	var lerp_speed = 0.4
	if zoomed:
		lerp_speed = 0.05

	camera.global_position = camera.global_position.lerp(target_position, lerp_speed)

func screen_to_world(screen_pos: Vector2) -> Vector2:
	return camera.get_canvas_transform().affine_inverse() * screen_pos

func reducir_cordura(valor: int) -> void:
	GLOBAL.cordura = max(GLOBAL.cordura - valor, 0)
	print("Cordura actual:", GLOBAL.cordura)

func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		iniciar_flash()

func iniciar_flash():
	flash_rect.visible = true
	flash_rect.modulate.a = 1.0
	flashing = true
	flash_timer = 0.0
