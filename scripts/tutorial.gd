extends Node2D

@onready var pato1 : Area2D = $Animales
@onready var pato2 : Area2D = $Animales2
@onready var menu_pausa = preload("res://menu_pausa/Menu_P.tscn").instantiate()

var PATO1_SPEED : float = randf_range(140, 180)
var PATO2_SPEED_X : float = randf_range(110, 150)
var PATO2_SPEED_Y : float = randf_range(90, 100)

var paused : bool = false  # Added to track pause state

const SCREEN_LIMIT_X = 1280
const SCREEN_LIMIT_Y = 0
const RESET_POSITION_X = -100
const RESET_POSITION_Y = 720

func _ready() -> void:
	# Initialize animations for pato1
	GLOBAL.cordura=100
	var anim1 = pato1.get_node_or_null("AnimatedSprite2D")
	if anim1:
		anim1.play()
		anim1.speed_scale = 1.5
	else:
		print("Error: AnimatedSprite2D not found in pato1")

	# Initialize animations for pato2
	var anim2 = pato2.get_node_or_null("AnimatedSprite2D")
	if anim2:
		anim2.play()
		anim2.speed_scale = 1.7
	else:
		print("Error: AnimatedSprite2D not found in pato2")

	# Add and configure pause menu
	add_child(menu_pausa)
	menu_pausa.process_mode = Node.PROCESS_MODE_ALWAYS
	menu_pausa.visible = false
	menu_pausa.z_index = 100
	menu_pausa.player_node = self  # Pass reference to this node
	
	# Ensure cursor is hidden at start
	print("Initializing in _ready, calling hide_cursor")
	hide_cursor()

func _process(delta: float) -> void:
	if get_tree().paused:
		print("Game is paused, skipping _process updates")
		return

	# Horizontal movement for pato1
	pato1.position.x += PATO1_SPEED * delta
	if pato1.position.x > SCREEN_LIMIT_X:
		pato1.position.x = RESET_POSITION_X

	# Diagonal movement for pato2
	if pato2:
		pato2.position.x += PATO2_SPEED_X * delta
		pato2.position.y -= PATO2_SPEED_Y * delta

	if pato2.position.x > SCREEN_LIMIT_X or pato2.position.y < SCREEN_LIMIT_Y:
		pato2.position.x = RESET_POSITION_X
		pato2.position.y = RESET_POSITION_Y

	# Handle pause with ESC
	if Input.is_action_just_pressed("ui_cancel"):
		print("ui_cancel pressed, current pause state: ", get_tree().paused)
		if not get_tree().paused:
			print("Pausing game...")
			paused = true
			get_tree().paused = true
			menu_pausa.visible = true
			if menu_pausa.has_method("show_pause_menu"):
				print("Calling show_pause_menu on menu_pausa")
				menu_pausa.show_pause_menu()
			else:
				print("Warning: show_pause_menu method not found in menu_pausa")
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			print("Mouse mode set to VISIBLE: ", Input.get_mouse_mode())
		else:
			print("Unpausing game via _process...")
			menu_pausa.exit_pause_menu()  # Call pause menu's exit method

func hide_cursor() -> void:
	# Force cursor to be hidden and confined
	print("Inside hide_cursor, setting mouse mode to CONFINED_HIDDEN")
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED_HIDDEN)
	# Verify and ensure cursor state
	if Input.get_mouse_mode() != Input.MOUSE_MODE_CONFINED_HIDDEN:
		print("Mouse mode mismatch, forcing CONFINED_HIDDEN")
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED_HIDDEN)
	print("Cursor mode after hide_cursor: ", Input.get_mouse_mode())

func resume_enemies() -> void:
	print("resume_enemies called, no specific enemy logic implemented")
